extends RefCounted

const FIXTURE = preload("res://tests/combat_fixture.gd")
var deaths := 0

func run(suite: SceneTree) -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    suite.root.add_child(main)
    main.start_run()
    var run: Node2D = main.run
    var rack := run.get_node("Player/WeaponRack")
    var player := run.get_node("Player")
    var enemies := run.get_node("Enemies")
    var attacks := run.get_node("Attacks")
    rack.set_physics_process(false)
    player.set_physics_process(false)
    enemies.get_child(0).free()
    suite._check(rack.equipped.size() == 1 and rack.equipped[0].id == &"spark", "normal loadout is only Spark")
    rack._physics_process(0.7)
    suite._check(attacks.get_child_count() == 0, "Spark with no targets emits nothing")
    var near := FIXTURE.add_enemy(run, player.position + Vector2(100, 0))
    var far := FIXTURE.add_enemy(run, player.position + Vector2(0, -200))
    near.set_physics_process(false)
    far.set_physics_process(false)
    rack._physics_process(0.69)
    suite._check(attacks.get_child_count() == 0, "no-target Spark does not bank a burst")
    rack._physics_process(0.01)
    suite._check(attacks.get_child_count() == 1, "Spark fires at data cadence")
    var shot := attacks.get_child(0)
    suite._check(shot.direction == Vector2.RIGHT and shot.damage == 10, "Spark targets nearest and uses rank data")
    for frame in range(24):
        await suite.physics_frame
    suite._check(near.get_node("Health").current == 190 and far.get_node("Health").current == 200, "Spark damages nearest only once and is consumed")
    suite._check(attacks.get_child_count() == 0, "hit projectile removed")
    suite._check(near.get_node("Visual").modulate.r > 1, "enemy hit flashes its silhouette")
    near._physics_process(0.2)
    suite._check(near.get_node("Visual").modulate == Color.WHITE, "enemy flash restores presentation tint")
    near.get_node("Health").died.connect(func(): deaths += 1)
    near.get_node("Health").take_damage(1000)
    suite._check(near.get_contact_damage() == 0, "dead enemy cannot hurt through a stale overlap")
    suite._check(not near.is_alive() and near.collision_layer == 0, "dead enemy immediately untargetable and noncolliding")
    suite._check(not near.get_node("Health").take_damage(1000) and deaths == 1, "enemy death emits once")
    rack._physics_process(0.7)
    suite._check(attacks.get_child_count() == 1, "Spark safely skips queued dead enemy")
    await suite.process_frame
    suite._check(not is_instance_valid(near), "dead enemy removed once")
    for attack in attacks.get_children():
        attack.free()
    far.free()
    FIXTURE.equip_all(run)
    suite._check(rack.equipped.size() == 4, "test-only fixture equips four weapons")
    # Real orbit overlaps, frozen angular motion to isolate the per-target window.
    rack._physics_process(0.01)
    var orbit := attacks.get_child(0)
    orbit.set_physics_process(false)
    var contact := FIXTURE.add_enemy(run, player.position + Vector2(36, 0))
    contact.set_physics_process(false)
    for frame in range(4):
        await suite.physics_frame
    orbit._physics_process(0.001)
    suite._check(contact.get_node("Health").current == 194, "Halo contact uses data damage")
    for frame in range(10):
        orbit._physics_process(0.01)
    suite._check(contact.get_node("Health").current == 194, "Halo cannot repeat within its hit window")
    orbit._physics_process(0.4)
    suite._check(contact.get_node("Health").current == 188, "Halo damages again after data cadence")
    var old_angle: float = orbit.angle
    player.position += Vector2(10, 0)
    orbit._physics_process(0.01)
    suite._check(orbit.angle > old_angle and is_equal_approx(orbit.global_position.distance_to(player.global_position), 36), "Halo rotates and follows player at data radius")
    # Renewal keeps the per-target window even at the lifetime boundary.
    orbit.remaining = 0.001
    var saved_hits: Dictionary = orbit.next_hit.duplicate()
    rack._physics_process(0.01)
    suite._check(orbit.remaining > 0.001 and orbit.next_hit == saved_hits, "Halo renewal preserves target cooldowns")
    orbit.free()
    contact.free()
    # Pulse affects the activation radius once; it is not a lingering hazard.
    var inside := FIXTURE.add_enemy(run, player.position + Vector2(50, 0))
    var outside := FIXTURE.add_enemy(run, player.position + Vector2(95, 0))
    inside.set_physics_process(false)
    outside.set_physics_process(false)
    for frame in range(3):
        await suite.physics_frame
    var pulse := preload("res://scenes/attacks/pulse.tscn").instantiate()
    pulse.configure(main.content.weapons[2], 2)
    attacks.add_child(pulse)
    pulse.global_position = player.global_position
    for frame in range(4):
        await suite.physics_frame
    suite._check(inside.get_node("Health").current == 182 and outside.get_node("Health").current == 200, "Pulse radius and rank-2 rounded damage are data driven")
    outside.position = player.position
    for frame in range(3):
        await suite.physics_frame
    suite._check(inside.get_node("Health").current == 182 and outside.get_node("Health").current == 200, "Pulse hits once and excludes late entrants")
    suite._check(player.get_node("Health").current == 100, "attacks never damage player")
    pulse.free()
    inside.free()
    outside.free()
    # All cardinal directions, cadence, lifetime, and swept high-speed hit.
    for index in rack.cooldowns.size():
        rack.cooldowns[index] = 10.0
    rack.cooldowns[3] = 0.02
    rack._physics_process(0.01)
    # Halo may exist, but Shard cannot fire early.
    suite._check(attacks.get_child_count() == 1, "Shard waits for cadence without target")
    rack._physics_process(0.01)
    suite._check(attacks.get_child_count() == 5, "Shard emits exactly four shots without targets")
    var directions: Array[Vector2] = []
    for attack in attacks.get_children():
        if attack.get_script() == preload("res://scripts/projectile.gd"):
            directions.append(attack.direction)
            suite._check(attack.collision_layer == 8 and attack.collision_mask == 4, "projectile scans only enemy layer")
    suite._check(directions.has(Vector2.UP) and directions.has(Vector2.DOWN) and directions.has(Vector2.LEFT) and directions.has(Vector2.RIGHT), "Shard covers four cardinal directions")
    # Remove Halo to isolate Shard damage at its orbital radius.
    for attack in attacks.get_children():
        if attack.get_script() == preload("res://scripts/orbit_attack.gd"):
            attack.free()
    var target := FIXTURE.add_enemy(run, player.position + Vector2(40, 0))
    target.set_physics_process(false)
    for frame in range(15):
        await suite.physics_frame
    suite._check(target.get_node("Health").current == 192, "Shard collision uses data damage once")
    for attack in attacks.get_children():
        attack.remaining = 0.001
    for frame in range(3):
        await suite.physics_frame
    suite._check(attacks.get_child_count() == 0, "unrenewed effects and missed projectiles expire")
    var fast := preload("res://scenes/attacks/projectile.tscn").instantiate()
    fast.configure(main.content.weapons[0], 3)
    fast.direction = Vector2.RIGHT
    fast.set_physics_process(false)
    attacks.add_child(fast)
    fast.global_position = player.global_position
    fast._physics_process(0.5)
    fast._hit(null)
    fast._hit(target)
    suite._check(target.get_node("Health").current == 177, "swept fast shot and overlap share one hit guard")
    await suite.process_frame
    target.free()
    # Pulse cadence is independent of its fading visual lifetime.
    rack.cooldowns[2] = 0.02
    rack.cooldowns[0] = 10.0
    rack.cooldowns[3] = 10.0
    rack._physics_process(0.01)
    rack._physics_process(0.01)
    suite._check(attacks.get_child_count() == 2, "Pulse fires at cadence with no targets")
    rack._physics_process(1.99)
    suite._check(attacks.get_child_count() == 2, "Pulse does not fire early")
    rack._physics_process(0.01)
    suite._check(attacks.get_child_count() == 3, "Pulse repeats at data cadence")
    var old_run := run
    player.get_node("Health").take_damage(1000)
    suite._check(not rack.is_physics_processing(), "defeat stops rack")
    await suite.process_frame
    suite._check(attacks.get_child_count() == 0, "defeat removes all attacks")
    main.retry_run()
    suite._check(main.run.get_node("Player/WeaponRack").equipped.size() == 1 and main.run.get_node("Attacks").get_child_count() == 0, "retry restores starting loadout without attacks")
    suite._check(main.run.get_node("Enemies/Enemy/Health").current == 20, "retry restores enemy health")
    await suite.process_frame
    suite._check(not is_instance_valid(old_run), "retry frees old rack and targets")
    main.run.get_node("SpawnDirector").next_spawn = INF
    for frame in range(130):
        await suite.physics_frame
    suite._check(main.run.get_node("Enemies").get_child_count() == 0, "normal rack automatically kills crawler without fire input")
    main.run.get_node("Player/Health").take_damage(1000)
    suite._check(main.run.ended, "defeat remains safe after all enemies have died")
    suite._check(main.content.weapons[0].rank_damage[0] == 10 and main.content.enemies[0].max_health == 20, "combat leaves content immutable")
    main.queue_free()
    await suite.process_frame
