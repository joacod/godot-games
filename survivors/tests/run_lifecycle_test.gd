extends RefCounted

func run(suite: SceneTree) -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    suite.root.add_child(main)
    main.start_run()
    var arena: Node2D = main.run
    var director := arena.get_node("SpawnDirector")
    arena.set_physics_process(false)
    arena.get_node("Player").set_physics_process(false)
    arena.get_node("Player/WeaponRack").set_physics_process(false)
    director.rng.seed = 12
    suite._check(director.interval_at(59.99) == 1.0 and is_equal_approx(director.interval_at(60), 0.65) and is_equal_approx(director.interval_at(120), 0.4), "spawn cadence changes at exact phase boundaries")
    director.advance(59.99, 0.01)
    suite._check(director.spawned_ordinary == 59, "first phase emits one crawler per second")
    director.advance(60, 0.01)
    suite._check(director.ordinary_count() == 60, "phase boundary respects living cap including starter")
    director.advance(119.99, 59.99)
    suite._check(director.ordinary_count() == 60 and director.spawned_elite == 0, "full cap consumes slots without accumulating a burst or early elite")
    director.advance(120, 0.01)
    suite._check(director.spawned_elite == 1 and director.ordinary_count() == 60, "elite appears once at 120 even with ordinary cap full")
    director.advance(121, 1)
    suite._check(director.spawned_elite == 1, "elite does not duplicate on later ticks")
    var elite: Node
    for enemy in arena.get_node("Enemies").get_children():
        enemy.set_physics_process(false)
        if enemy.content.elite:
            elite = enemy
    suite._check(elite.get_node("Health").current == 240 and elite.get_node("Label").text == main.content.enemies[1].display_name and elite.get_node("Visual").scale.x > 1, "elite uses distinct silhouette label and data stats")
    var player: Node2D = arena.get_node("Player")
    for at in [Vector2(24, 24), Vector2(936, 616), Vector2(480, 320)]:
        player.position = at
        var entry: Dictionary = director.entry_position()
        suite._check(entry.at.distance_to(player.position) >= 160, "entry stays away from player at %s" % at)
        suite._check(Rect2(Vector2(20, 20), Vector2(920, 600)).has_point(entry.at), "entry stays within walls")
    # Zoom out so the entire arena is visible: fallback must warn before entry.
    var camera: Camera2D = player.get_node("Camera2D")
    camera.zoom = Vector2(0.3, 0.3)
    suite._check(director.entry_position().marked, "fully visible arena selects marked edge fallback")
    director._request(false)
    suite._check(director.pending.size() == 1, "marked entry reserves a telegraph")
    var count_before: int = director.spawned_ordinary
    director.next_spawn = INF
    director.advance(121.6, 0.6)
    suite._check(director.spawned_ordinary == count_before, "marked threat waits for warning")
    director.advance(121.7, 0.1)
    suite._check(director.spawned_ordinary == count_before + 1 and director.pending.is_empty(), "warning completes with one edge entry")
    # Pause freezes actual physics, scheduler, attacks, damage and pickups.
    arena.set_physics_process(true)
    var elapsed_before: float = arena.elapsed
    var scheduled_before: float = director.next_spawn
    main.pause_run()
    for frame in 3:
        await suite.physics_frame
    director.advance(150, 10)
    suite._check(suite.paused and main.pause_menu.visible and arena.elapsed == elapsed_before and director.next_spawn == scheduled_before, "manual pause freezes timer and spawn schedule")
    suite._check(not player.get_node("Health").take_damage(10), "manual pause rejects contact damage")
    main.resume_run()
    await suite.physics_frame
    await suite.physics_frame
    suite._check(not suite.paused and arena.elapsed > elapsed_before, "resume advances active time")
    arena.set_physics_process(false)
    director._request(false)
    arena._drop_gem(player.position + Vector2(20, 0), 5)
    var gem := arena.get_node("Gems").get_child(0)
    arena.elapsed = 179.99
    arena._physics_process(0.02)
    suite._check(arena.ended and arena.outcome == "victory" and arena.elapsed == 180, "living player wins at 180 active seconds")
    suite._check(main.defeat.visible and main.defeat.get_node("Center/Column/Title").text == "The clearing holds", "victory presents focused retry result")
    suite._check(not player.get_node("Health").take_damage(1000), "victory rejects subsequent damage")
    var xp_before: int = arena.get_node("XP").xp
    gem.collect()
    arena._drop_gem(player.position, 5)
    var total_before: int = director.spawned_ordinary
    director.advance(200, 20)
    arena._physics_process(20)
    suite._check(not gem.spent and arena.get_node("XP").xp == xp_before, "outcome stops pickup grants and deferred drops")
    suite._check(director.spawned_ordinary == total_before and director.pending.is_empty() and arena.elapsed == 180, "outcome cancels warnings and late spawns and freezes time")
    main.retry_run()
    suite._check(main.run.elapsed == 0 and not main.run.ended, "retry begins with zero active time")
    await suite.process_frame
    suite._check(not is_instance_valid(arena) and main.run.elapsed < 0.1 and not main.run.ended, "victory retry frees old run and resets time")
    suite._check(main.run.get_node("SpawnDirector").spawned_elite == 0 and not main.run.get_node("SpawnDirector").elite_spawned and main.run.get_node("Gems").get_child_count() == 0, "retry clears elite history and gems")
    # Lethal contact in the same actual physics tick as the deadline.
    arena = main.run
    arena.elapsed = 180 - 1.0 / 120.0
    arena.get_node("Player/WeaponRack").set_physics_process(false)
    var health := arena.get_node("Player/Health")
    health.current = 10
    var enemy := arena.get_node("Enemies/Enemy")
    enemy.position = arena.get_node("Player").position
    # Establish an overlap while time/contact processing is held.
    arena.set_physics_process(false)
    arena.get_node("Player").set_physics_process(false)
    enemy.set_physics_process(false)
    for frame in 5:
        await suite.physics_frame
    suite._check(arena.get_node("Player/Hurtbox").get_overlapping_bodies().has(enemy), "final-tick fixture establishes physical contact")
    arena.set_physics_process(true)
    arena.get_node("Player").set_physics_process(true)
    await suite.physics_frame
    await suite.physics_frame
    suite._check(arena.outcome == "defeat" and health.current == 0, "actual final-tick lethal contact takes precedence over timeout")
    suite._check(main.defeat.get_node("Center/Column/Title").text == "The light fades", "defeat replaces previous victory text")
    main.retry_run()
    suite._check(main.run.get_node("Player/Health").current == 100 and main.run.get_node("XP").level == 1 and main.run.get_node("Player/WeaponRack").equipped.size() == 1, "loss retry restores starting health progression and loadout")
    arena = main.run
    director = arena.get_node("SpawnDirector")
    arena.get_node("Player/Camera2D").zoom = Vector2(0.3, 0.3)
    director.next_spawn = INF
    director.advance(120, 0)
    elite = arena.get_node("Enemies").get_child(1)
    suite._check(director.spawned_elite == 1 and elite.entry_delay == 0.7 and director.pending.size() == 1, "visible elite appears on deadline with a warning")
    suite._check(elite.get_contact_damage() == 0 and not elite.get_node("Health").take_damage(10), "marked elite is harmless and invulnerable during entry")
    main.pause_run()
    for frame in 3:
        await suite.physics_frame
    suite._check(elite.entry_delay == 0.7, "pause freezes marked elite activation")
    main.resume_run()
    for frame in 45:
        await suite.physics_frame
    suite._check(elite.entry_delay == 0 and elite.get_node("Health").active and elite.get_contact_damage() == 20, "elite activates after its warning using content damage")
    main.return_to_menu()
    suite._check(not suite.paused and not main.pause_menu.visible and main.menu.visible, "menu return restores unpaused menu")
    main.queue_free()
    await suite.process_frame
