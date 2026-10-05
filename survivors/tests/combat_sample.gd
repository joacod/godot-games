extends SceneTree

# Native-only visual fixture. It adds no debug controls to the game flow.
func _initialize() -> void:
    call_deferred("_sample")

func _sample() -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    main.start_run()
    var run: Node2D = main.run
    run.set_physics_process(false)
    preload("res://tests/combat_fixture.gd").equip_all(run)
    for offset in [Vector2(-100, 0), Vector2(0, -130), Vector2(0, 120), Vector2(170, 80), Vector2(36, 0)]:
        preload("res://tests/combat_fixture.gd").add_enemy(run, run.get_node("Player").position + offset, 500)
    var started := Time.get_ticks_msec()
    var captured: Dictionary = {}
    var current_action := ""
    while Time.get_ticks_msec() - started < 15000:
        var elapsed := (Time.get_ticks_msec() - started) / 1000.0
        var action: String = ["move_left", "move_up", "move_right", "move_down"][int(elapsed / 2.0) % 4]
        if action != current_action:
            if not current_action.is_empty():
                Input.action_release(current_action)
            Input.action_press(action)
            current_action = action
        for stamp in [2.08, 6.08, 12.08]:
            if elapsed >= stamp and not captured.has(stamp):
                RenderingServer.force_draw(false)
                root.get_texture().get_image().save_png("/private/tmp/survivors-step03-%.2f.png" % stamp)
                captured[stamp] = true
        await process_frame
    Input.action_release(current_action)
    print("Native sample: 15 seconds; ended=%s; HP=%d; captures=%d" % [run.ended, run.get_node("Player/Health").current, captured.size()])
    main.queue_free()
    await process_frame
    quit()
