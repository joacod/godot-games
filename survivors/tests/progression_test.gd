extends RefCounted

const FIXTURE = preload("res://tests/combat_fixture.gd")

func _upgrade(run: Node, id: StringName) -> SurvivorUpgradeData:
    for upgrade in run.content.upgrades:
        if upgrade.id == id:
            return upgrade
    return null

func _ids(options: Array[SurvivorUpgradeData]) -> Array[StringName]:
    var result: Array[StringName] = []
    for option in options:
        result.append(option.id)
    return result

func run(suite: SceneTree) -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    suite.root.add_child(main)
    main.start_run()
    var arena: Node2D = main.run
    var player := arena.get_node("Player")
    var rack := player.get_node("WeaponRack")
    var health := player.get_node("Health")
    var xp := arena.get_node("XP")
    var upgrades := arena.get_node("Upgrades")
    rack.set_physics_process(false)
    player.set_physics_process(false)
    var enemy := arena.get_node("Enemies/Enemy")
    enemy.set_physics_process(false)
    enemy.get_node("Health").take_damage(100)
    enemy.get_node("Health").take_damage(100)
    await suite.process_frame
    suite._check(arena.get_node("Gems").get_child_count() == 1, "one death drops exactly one data-reward gem")
    var gem := arena.get_node("Gems").get_child(0)
    gem.set_physics_process(false)
    suite._check(gem.amount == 5 and gem.collision_layer == 16, "gem uses enemy XP and pickup layer")
    gem.position = player.position + Vector2(49, 0)
    gem._physics_process(0.02)
    suite._check(not gem.attracted, "gem outside magnet radius stays put")
    player.position += Vector2(2, 0)
    var distance: float = gem.position.distance_to(player.position)
    gem._physics_process(0.02)
    suite._check(gem.attracted and gem.position.distance_to(player.position) < distance, "nearby gem attracts toward player")
    player.position -= Vector2(100, 0)
    gem._physics_process(0.02)
    suite._check(gem.attracted, "attracted gem follows after player leaves radius")
    gem.position = player.position
    gem._physics_process(0.02)
    gem.collect()
    suite._check(xp.xp == 5 and gem.spent, "gem collection awards XP only once")
    await suite.process_frame
    xp.grant(4)
    suite._check(xp.level == 1 and xp.xp == 9 and not suite.paused, "XP below boundary does not open menu")
    xp.grant(1)
    suite._check(xp.level == 2 and xp.xp == 0 and xp.threshold() == 15, "exact threshold advances level with data cost")
    suite._check(suite.paused and main.upgrade_menu.visible and xp.pending_levels == 1, "level pauses tree and opens one panel")
    suite._check(_ids(main.upgrade_menu.choices).has(&"upgrade_halo") and _ids(main.upgrade_menu.choices).has(&"upgrade_spark"), "first panel prioritizes unowned weapon and Spark rank")
    var damage_enemy := FIXTURE.add_enemy(arena, player.position, 100)
    damage_enemy.set_physics_process(false)
    var frozen_attack := preload("res://scenes/attacks/projectile.tscn").instantiate()
    frozen_attack.configure(main.content.weapons[0], 1)
    arena.get_node("Attacks").add_child(frozen_attack)
    frozen_attack.position = player.position + Vector2(0, -150)
    var lifetime_before: float = frozen_attack.remaining
    var paused_gem := preload("res://scenes/xp_gem.tscn").instantiate()
    paused_gem.actor = player
    paused_gem.upgrades = upgrades
    paused_gem.amount = 5
    arena.get_node("Gems").add_child(paused_gem)
    paused_gem.position = player.position
    var position_before: Vector2 = player.position
    var cooldown_before: Array = rack.cooldowns.duplicate()
    var hp_before: int = health.current
    var immunity_before: float = health.invulnerability_remaining
    rack.set_physics_process(true)
    player.set_physics_process(true)
    Input.action_press("move_right")
    await suite.create_timer(0.08).timeout
    Input.action_release("move_right")
    suite._check(player.position == position_before and rack.cooldowns == cooldown_before and health.current == hp_before and health.invulnerability_remaining == immunity_before, "paused tree freezes movement damage immunity and attack cadence")
    paused_gem.collect()
    suite._check(frozen_attack.remaining == lifetime_before and not paused_gem.spent, "pause freezes attack lifetime and suppresses gem collection")
    paused_gem.free()
    frozen_attack.free()
    suite._check(not health.take_damage(10), "paused direct contact cannot damage player")
    var press := InputEventKey.new()
    press.physical_keycode = KEY_ENTER
    press.keycode = KEY_ENTER
    press.pressed = true
    Input.parse_input_event(press)
    await suite.process_frame
    main.upgrade_menu.select(0)
    main.upgrade_menu.select(1)
    await suite.process_frame
    suite._check(suite.paused and upgrades.rank(&"halo") == 0, "held confirm keeps choice pending and blocks a second selection")
    var release := press.duplicate() as InputEventKey
    release.pressed = false
    Input.parse_input_event(release)
    await suite.process_frame
    await suite.process_frame
    suite._check(not suite.paused and xp.pending_levels == 0 and upgrades.rank(&"halo") == 1 and upgrades.rank(&"spark") == 1, "released confirmation applies exactly one choice then resumes")
    player.set_physics_process(false)
    rack.set_physics_process(false)
    damage_enemy.free()
    xp.grant(54)
    suite._check(xp.level == 4 and xp.xp == 19 and xp.pending_levels == 2 and xp.choice_level() == 3, "multi-level grant preserves overflow and queues panels in order")
    suite._check(_ids(main.upgrade_menu.choices).has(&"lens"), "Lens offered by level 3")
    main.upgrade_menu.select(0)
    await suite.process_frame
    await suite.process_frame
    suite._check(suite.paused and xp.pending_levels == 1 and xp.choice_level() == 4, "resolving queued panel keeps next panel paused")
    main.upgrade_menu.select(0)
    await suite.process_frame
    await suite.process_frame
    suite._check(not suite.paused and xp.pending_levels == 0, "queue resumes only after all panels resolve")
    xp.grant(0)
    xp.grant(-5)
    suite._check(xp.xp == 19, "nonpositive XP grants ignored")
    # Both acquisition orders; slot identity changes without mutating Resources.
    for lens_first in [false, true]:
        main.retry_run()
        arena = main.run
        player = arena.get_node("Player")
        rack = player.get_node("WeaponRack")
        upgrades = arena.get_node("Upgrades")
        health = player.get_node("Health")
        rack.set_physics_process(false)
        player.set_physics_process(false)
        arena.get_node("Enemies/Enemy").set_physics_process(false)
        FIXTURE.equip_all(arena)
        var before: Array = rack.slot_ids.duplicate()
        if lens_first:
            upgrades.apply(_upgrade(arena, &"lens"))
        upgrades.apply(_upgrade(arena, &"upgrade_spark"))
        rack._physics_process(0.7)
        var old_shot: Node = null
        for attack in arena.get_node("Attacks").get_children():
            if attack.weapon.id == &"spark":
                old_shot = attack
        suite._check(old_shot != null, "pre-evolution Spark shot exists")
        upgrades.apply(_upgrade(arena, &"upgrade_spark"))
        if not lens_first:
            suite._check(not upgrades.evolved, "rank-3 Spark waits for Lens")
            upgrades.apply(_upgrade(arena, &"lens"))
        suite._check(upgrades.evolved and rack.slot_ids[0] == &"arc_spark" and rack.equipped.size() == 4 and rack.ranks[0] == 3, "either recipe order evolves in original slot at rank 3")
        suite._check(rack.slot_ids.slice(1) == before.slice(1) and rack.chain_limits[0] == 3, "evolution preserves other weapon slots and uses data chain limit")
        suite._check(old_shot.is_queued_for_deletion(), "evolution removes old Spark attacks")
        suite._check(not upgrades.apply(_upgrade(arena, &"lens")) and not upgrades.apply(_upgrade(arena, &"upgrade_spark")), "evolved Spark and owned Lens cannot be acquired again")
        for index in range(1, 4):
            rack.ranks[index] = 3
        suite._check(is_equal_approx(upgrades.pickup_radius, 80), "Lens radius uses data")
        upgrades.apply(_upgrade(arena, &"recovery"))
        upgrades.apply(_upgrade(arena, &"recovery"))
        suite._check(health.current == 100 and health.shield == 40, "Recovery at full HP adds shield even with an existing shield")
        var options: Array = _ids(upgrades.offers(20))
        suite._check(options.size() == 3 and options.has(&"recovery") and options.has(&"power") and options.has(&"reach"), "exhausted ranks and Lens leave three distinct effective fallbacks")
        var old_damage: int = rack.damage_for(0)
        upgrades.apply(_upgrade(arena, &"power"))
        upgrades.apply(_upgrade(arena, &"reach"))
        suite._check(rack.damage_for(0) > old_damage and upgrades.pickup_radius == 88, "Power raises weapon damage and Reach extends Lens")
        health.take_damage(45)
        suite._check(health.shield == 0 and health.current == 95, "shield absorbs before HP and permits damage overflow")
        upgrades.apply(_upgrade(arena, &"recovery"))
        suite._check(health.current == 100 and health.shield == 15, "Recovery converts only unused healing into shield")
        await suite.process_frame
    # Chain uses real projectile movement/physics with distinct target IDs.
    for attack in arena.get_node("Attacks").get_children():
        attack.free()
    for enemy_node in arena.get_node("Enemies").get_children():
        enemy_node.free()
    var targets: Array[CharacterBody2D] = []
    for offset in [Vector2(40, 0), Vector2(90, 0), Vector2(90, 50), Vector2(160, 50)]:
        var target := FIXTURE.add_enemy(arena, player.position + offset, 100)
        target.set_physics_process(false)
        targets.append(target)
    for index in rack.cooldowns.size():
        rack.cooldowns[index] = 10.0
    rack.cooldowns[0] = 0.0
    rack._physics_process(0.01)
    var shot: Node
    for attack in arena.get_node("Attacks").get_children():
        if attack.weapon.id == &"spark":
            shot = attack
        else:
            attack.free()
    var chain_damage: int = shot.damage
    for frame in 60:
        await suite.physics_frame
    suite._check(targets[0].get_node("Health").current == 100 - chain_damage and targets[1].get_node("Health").current == 100 - chain_damage and targets[2].get_node("Health").current == 100 - chain_damage and targets[3].get_node("Health").current == 100, "Arc Spark flies through exactly three distinct targets once each")
    suite._check(not is_instance_valid(shot), "chain projectile consumed after target limit")
    upgrades.apply(_upgrade(arena, &"reach"))
    var gem2 := preload("res://scenes/xp_gem.tscn").instantiate()
    gem2.actor = player
    gem2.upgrades = upgrades
    gem2.amount = 5
    arena.get_node("Gems").add_child(gem2)
    gem2.position = player.position + Vector2(90, 0)
    gem2._physics_process(0.01)
    suite._check(gem2.attracted, "Lens plus repeatable Reach affects actual attraction")
    arena.get_node("XP").grant(100)
    suite._check(suite.paused, "retry fixture has queued levels")
    var old_run := arena
    main.retry_run()
    await suite.process_frame
    suite._check(not suite.paused and not main.upgrade_menu.visible and not is_instance_valid(old_run), "retry during choice frees old progression and unpauses")
    var fresh: Node = main.run
    suite._check(fresh.get_node("XP").xp == 0 and fresh.get_node("XP").level == 1 and fresh.get_node("XP").pending_levels == 0, "retry resets XP levels and choice queue")
    suite._check(not fresh.get_node("Upgrades").lens_owned and not fresh.get_node("Upgrades").evolved and fresh.get_node("Upgrades").pickup_radius == 48, "retry resets passive evolution and pickup modifiers")
    suite._check(fresh.get_node("Player/WeaponRack").ranks == [1] and fresh.get_node("Player/WeaponRack").power_bonus == 0 and fresh.get_node("Player/Health").shield == 0 and fresh.get_node("Gems").get_child_count() == 0, "retry resets ranks power shield and gems")
    suite._check(main.content.weapons[0].id == &"spark" and main.content.weapons[0].rank_damage[2] == 15 and main.content.pickup_radius == 48, "progression leaves shipped Resources immutable")
    var fresh_upgrades := fresh.get_node("Upgrades")
    fresh_upgrades.apply(_upgrade(fresh, &"reach"))
    fresh_upgrades.apply(_upgrade(fresh, &"lens"))
    suite._check(fresh_upgrades.pickup_radius == 88, "Lens acquisition retains earlier Reach bonus")
    fresh.get_node("XP").grant(10)
    main.return_to_menu()
    await suite.process_frame
    suite._check(not suite.paused and main.menu.visible and not main.upgrade_menu.visible, "menu return cancels queued selection and restores tree processing")
    main.queue_free()
    await suite.process_frame
