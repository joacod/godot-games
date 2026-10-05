extends RefCounted

var deaths := 0
var outcomes := 0

func run(suite: SceneTree) -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    suite.root.add_child(main)
    main.start_run()
    var run: Node2D = main.run
    var player: CharacterBody2D = run.get_node("Player")
    var enemy: CharacterBody2D = run.get_node("Enemy")
    var health: Node = player.get_node("Health")
    enemy.set_physics_process(false)
    await suite.physics_frame
    await suite.physics_frame
    Input.action_press("move_right")
    await suite.physics_frame
    await suite.physics_frame
    var straight := player.velocity.length()
    Input.action_press("move_down")
    await suite.physics_frame
    await suite.physics_frame
    suite._check(is_equal_approx(straight, main.content.character.speed), "cardinal input uses content speed")
    suite._check(is_equal_approx(straight, player.velocity.length()), "diagonal speed equals cardinal speed")
    Input.action_release("move_right")
    Input.action_release("move_down")
    await suite.physics_frame
    await suite.physics_frame
    suite._check(player.velocity.is_zero_approx(), "releasing input stops motion")
    # Real held input into each wall, after placing near it.
    for fixture in [[Vector2(11, 320), "move_left"], [Vector2(949, 320), "move_right"], [Vector2(430, 11), "move_up"], [Vector2(430, 629), "move_down"]]:
        player.position = fixture[0]
        Input.action_press(fixture[1])
        for frame in range(5):
            await suite.physics_frame
        Input.action_release(fixture[1])
        suite._check(player.position.x >= 9.9 and player.position.x <= 950.1 and player.position.y >= 9.9 and player.position.y <= 630.1, "held input cannot cross " + fixture[1])
        player.get_node("Camera2D").force_update_scroll()
        var center: Vector2 = player.get_node("Camera2D").get_screen_center_position()
        suite._check(center.x >= 256 and center.x <= 704 and center.y >= 116 and center.y <= 524, "camera stays within arena presentation margin at " + fixture[1])
    player.position = Vector2(430, 320)
    enemy.position = Vector2(640, 320)
    enemy.set_physics_process(true)
    var distance := enemy.position.distance_to(player.position)
    for frame in range(12):
        await suite.physics_frame
    suite._check(enemy.position.distance_to(player.position) < distance, "crawler pursues player")
    suite._check(is_equal_approx(enemy.velocity.length(), main.content.enemies[0].speed), "pursuit uses content speed")
    enemy.set_physics_process(false)
    enemy.position = player.position
    health.died.connect(func(): deaths += 1)
    run.defeated.connect(func(): outcomes += 1)
    for frame in range(5):
        await suite.physics_frame
    suite._check(health.current == 90, "overlap delivers one contact hit")
    suite._check(player.flash_remaining > 0 and player.get_node("Visual").modulate.r > 1, "damage flashes player silhouette")
    suite._check(main.arena_ui.get_node("Header").text == "HP 90 / 100", "damage updates visible health")
    suite._check(not health.take_damage(10), "additional hit shares player invulnerability")
    for frame in range(25):
        await suite.physics_frame
    suite._check(health.current == 90, "persistent contact cannot damage before interval")
    suite._check(player.flash_remaining == 0 and player.get_node("Visual").modulate == Color.WHITE, "flash ends without changing base art tint")
    for frame in range(20):
        await suite.physics_frame
    suite._check(health.current == 80, "persistent contact damages again after interval")
    enemy.position = Vector2(640, 320)
    for frame in range(45):
        await suite.physics_frame
    suite._check(health.current == 80, "leaving contact stops further damage")
    suite._check(not health.take_damage(0) and not health.take_damage(-5), "nonpositive damage has no effect")
    suite._check(health.take_damage(1000) and health.current == 0, "lethal damage clamps health to zero")
    suite._check(deaths == 1 and outcomes == 1, "death and defeat emit once")
    suite._check(not health.take_damage(1000) and deaths == 1, "dead player rejects repeated damage")
    suite._check(main.defeat.visible and main.defeat.get_node("Center/Column/Retry").has_focus(), "defeat shows focused Retry")
    var stopped_player := player.position
    var stopped_enemy := enemy.position
    Input.action_press("move_left")
    for frame in range(5):
        await suite.physics_frame
    Input.action_release("move_left")
    suite._check(player.position == stopped_player and enemy.position == stopped_enemy, "defeat stops movement and pursuit")
    main.defeat.get_node("Center/Column/Retry").pressed.emit()
    suite._check(main.run != run and not main.run.ended, "Retry constructs a new active run")
    suite._check(main.run.get_node("Player/Health").current == 100 and main.run.get_node("Player/Health").invulnerability_remaining == 0, "Retry restores health and clears immunity")
    suite._check(main.run.get_node("Player").position == Vector2(430, 320) and main.run.get_node("Enemy").position == Vector2(640, 320), "Retry restores actor positions")
    suite._check(not main.defeat.visible and not main.menu.visible, "Retry returns to gameplay")
    suite._check(main.content.character.max_health == 100 and main.content.enemies[0].contact_damage == 10, "damage and retry leave content immutable")
    await suite.process_frame
    suite._check(not is_instance_valid(run), "Retry frees previous run")
    main.return_to_menu()
    suite._check(main.run == null and main.menu.visible and not main.defeat.visible, "Back restores menu after retry")
    main.queue_free()
    await suite.process_frame
