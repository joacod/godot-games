extends SceneTree

# Real-time native route, normal content and drops; scripted movement/choices.
var main: Node
var actions: Array[String] = []
var captures: Dictionary = {}
var evolved_at := -1.0
var all_weapons_at := -1.0
var choices: Array[String] = []
var choosing := false

func _initialize() -> void:
    call_deferred("_panels" if "--panels" in OS.get_cmdline_user_args() else "_sample")

func _capture(label: String) -> void:
    await process_frame
    RenderingServer.force_draw(false)
    root.get_texture().get_image().save_png("/private/tmp/survivors-step05-%s.png" % label)

func _move(direction: Vector2) -> void:
    for action in actions:
        Input.action_release(action)
    actions.clear()
    if direction.x < -0.25:
        actions.append("move_left")
    elif direction.x > 0.25:
        actions.append("move_right")
    if direction.y < -0.25:
        actions.append("move_up")
    elif direction.y > 0.25:
        actions.append("move_down")
    for action in actions:
        Input.action_press(action)

func _choose() -> void:
    choosing = true
    _move(Vector2.ZERO)
    var state: Node = main.run.get_node("Upgrades")
    var selected := 0
    # Take each remaining weapon, then Lens and Spark ranks. No injected XP.
    for index in main.upgrade_menu.choices.size():
        var choice: SurvivorUpgradeData = main.upgrade_menu.choices[index]
        if choice.kind == SurvivorUpgradeData.Kind.WEAPON and state.rank(choice.target_id) == 0:
            selected = index
            break
        if choice.kind == SurvivorUpgradeData.Kind.PASSIVE or (choice.target_id == &"spark" and not state.evolved):
            selected = index
            break
        if choice.id == &"recovery":
            selected = index
    choices.append("%.2fs %s" % [main.run.elapsed, main.upgrade_menu.choices[selected].id])
    main.upgrade_menu._button(selected).grab_focus()
    var press := InputEventKey.new()
    press.keycode = KEY_ENTER
    press.physical_keycode = KEY_ENTER
    press.pressed = true
    Input.parse_input_event(press)
    await create_timer(0.12).timeout
    var release := press.duplicate() as InputEventKey
    release.pressed = false
    Input.parse_input_event(release)
    await process_frame
    await process_frame
    choosing = false

func _direction() -> Vector2:
    var run: Node2D = main.run
    var player: Node2D = run.get_node("Player")
    var target := Vector2(480, 320)
    var distance := INF
    for gem in run.get_node("Gems").get_children():
        if gem.spent:
            continue
        var candidate: float = player.position.distance_squared_to(gem.position)
        if candidate < distance:
            target = gem.position
            distance = candidate
    var direction := player.position.direction_to(target)
    if distance < 400:
        direction = Vector2.ZERO
    for enemy in run.get_node("Enemies").get_children():
        if not enemy.is_alive():
            continue
        var separation: Vector2 = player.position - enemy.position
        if separation.length() < 65:
            direction += separation.normalized() * (1.0 - separation.length() / 65) * 2.0
    return direction.normalized()

func _sample() -> void:
    create_timer(280).timeout.connect(func():
        push_error("Native run sample timed out")
        quit(1)
    )
    main = preload("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    main.start_run()
    var wall_started := Time.get_ticks_msec()
    var report_at := 20.0
    while not main.run.ended:
        if main.upgrade_menu.visible and not choosing:
            await _choose()
        else:
            _move(_direction())
        var run: Node2D = main.run
        if run.get_node("Upgrades").evolved and evolved_at < 0:
            evolved_at = run.elapsed
        if run.get_node("Player/WeaponRack").equipped.size() == 4 and all_weapons_at < 0:
            all_weapons_at = run.elapsed
        for stamp in [45, 90, 121, 150]:
            if run.elapsed >= stamp and not captures.has(stamp):
                captures[stamp] = true
                await _capture("%ds" % stamp)
        if run.elapsed >= report_at:
            print("Route %.2fs HP=%d level=%d gems=%d enemies=%d evolved=%s" % [run.elapsed, run.get_node("Player/Health").current, run.get_node("XP").level, run.get_node("Gems").get_child_count(), run.get_node("Enemies").get_child_count(), run.get_node("Upgrades").evolved])
            report_at += 20
        await process_frame
    _move(Vector2.ZERO)
    await _capture("result")
    print("Native route outcome=%s active=%.2f wall=%.2f all_weapons=%.2f evolved=%.2f elite=%d choices=%s" % [main.run.outcome, main.run.elapsed, (Time.get_ticks_msec() - wall_started) / 1000.0, all_weapons_at, evolved_at, main.run.get_node("SpawnDirector").spawned_elite, choices])
    var won: bool = main.run.outcome == "victory" and all_weapons_at >= 0 and all_weapons_at <= 150 and evolved_at >= 0 and evolved_at <= 150
    main.retry_run()
    # Deliberately move into the nearest threat with normal HP and attacks.
    while not main.run.ended and main.run.elapsed < 55:
        if main.upgrade_menu.visible:
            await _choose()
        else:
            var player: Node2D = main.run.get_node("Player")
            var nearest: Node2D
            var best := INF
            for enemy in main.run.get_node("Enemies").get_children():
                var candidate: float = player.position.distance_squared_to(enemy.position)
                if enemy.is_alive() and candidate < best:
                    nearest = enemy
                    best = candidate
            _move(player.position.direction_to(nearest.position) if is_instance_valid(nearest) else Vector2.ZERO)
        await process_frame
    _move(Vector2.ZERO)
    await _capture("loss")
    print("Short loss route outcome=%s active=%.2f HP=%d" % [main.run.outcome, main.run.elapsed, main.run.get_node("Player/Health").current])
    var lost: bool = main.run.outcome == "defeat"
    main.retry_run()
    await _capture("retry")
    print("Retry HP=%d level=%d XP=%d weapons=%d elite=%s" % [main.run.get_node("Player/Health").current, main.run.get_node("XP").level, main.run.get_node("XP").xp, main.run.get_node("Player/WeaponRack").equipped.size(), main.run.get_node("SpawnDirector").elite_spawned])
    main.queue_free()
    await process_frame
    quit(0 if won and lost else 1)

func _panels() -> void:
    # Short visual fixture; elapsed time and elite placement are controlled here.
    create_timer(8).timeout.connect(func(): quit(1))
    main = preload("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    main.start_run()
    main.pause_run()
    var before: float = main.run.elapsed
    await _capture("pause")
    await create_timer(0.3).timeout
    print("Native manual pause: timer unchanged=%s" % (main.run.elapsed == before))
    main.resume_run()
    var run: Node2D = main.run
    var elite: CharacterBody2D = run.spawn_enemy(run.get_node("Player").position + Vector2(110, 50), run.content.enemies[1])
    elite.set_physics_process(false)
    await _capture("elite")
    run.get_node("Player/Camera2D").zoom = Vector2(0.3, 0.3)
    var director := run.get_node("SpawnDirector")
    director.next_spawn = INF
    director.advance(120, 0)
    await _capture("warning")
    print("Native visible entry: warned=%d scheduled elite=%d" % [director.pending.size(), director.spawned_elite])
    main.return_to_menu()
    main.queue_free()
    await process_frame
    quit()
