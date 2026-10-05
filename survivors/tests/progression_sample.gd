extends SceneTree

# Native fixture: manually supplied gems/XP and enemies; no spawn director.
var main: Node

func _initialize() -> void:
    call_deferred("_sample")

func _capture(label: String) -> void:
    await process_frame
    RenderingServer.force_draw(false)
    root.get_texture().get_image().save_png("/private/tmp/survivors-step04-%s.png" % label)

func _choose(index: int) -> void:
    var button: Button = main.upgrade_menu._button(index)
    button.grab_focus()
    var press := InputEventKey.new()
    press.keycode = KEY_ENTER
    press.physical_keycode = KEY_ENTER
    press.pressed = true
    Input.parse_input_event(press)
    await create_timer(0.15).timeout
    var release := press.duplicate() as InputEventKey
    release.pressed = false
    Input.parse_input_event(release)
    await process_frame
    await process_frame

func _sample() -> void:
    create_timer(12.0).timeout.connect(func(): quit(1))
    main = preload("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    main.start_run()
    var run: Node2D = main.run
    run.set_physics_process(false)
    var player := run.get_node("Player")
    run.get_node("Enemies/Enemy").get_node("Health").take_damage(100)
    await process_frame
    var gem := run.get_node("Gems").get_child(0)
    gem.position = player.position + Vector2(45, 0)
    var distant := preload("res://tests/combat_fixture.gd").add_enemy(run, player.position + Vector2(150, -50), 200)
    distant.set_physics_process(false)
    await _capture("attraction")
    await create_timer(0.4).timeout
    run.get_node("XP").grant(5)
    await _capture("choices")
    var before: Vector2 = distant.position
    var hp: int = player.get_node("Health").current
    await create_timer(0.25).timeout
    print("Native pause: paused=%s; unchanged enemy=%s; HP=%d/%d" % [paused, distant.position == before, player.get_node("Health").current, hp])
    await _choose(0) # Halo unlock
    run.get_node("XP").grant(15)
    await _capture("lens-offer")
    await _choose(1) # Lens
    run.get_node("XP").grant(20)
    await _choose(1) # Spark rank 2 (unowned, Spark, other)
    run.get_node("XP").grant(25)
    await _choose(1) # Spark rank 3, Arc Spark
    for offset in [Vector2(80, 10), Vector2(110, 50), Vector2(150, 75)]:
        var enemy := preload("res://tests/combat_fixture.gd").add_enemy(run, player.position + offset, 200)
        enemy.set_physics_process(false)
    await create_timer(0.9).timeout
    await _capture("evolved")
    run.get_node("XP").grant(30)
    var state := run.get_node("Upgrades")
    while paused:
        await _choose(0)
    state.apply(_find(run, &"recovery"))
    state.apply(_find(run, &"recovery"))
    main._update_health(player.get_node("Health").current, 100)
    await _capture("shield")
    main.retry_run()
    await _capture("retry")
    print("Native progression: six captures; injected Enter choices; retry level=%d XP=%d; paused=%s" % [main.run.get_node("XP").level, main.run.get_node("XP").xp, paused])
    main.queue_free()
    await process_frame
    quit()

func _find(run: Node, id: StringName) -> SurvivorUpgradeData:
    for upgrade in run.content.upgrades:
        if upgrade.id == id:
            return upgrade
    return null
