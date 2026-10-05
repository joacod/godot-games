extends RefCounted

func run(suite: SceneTree) -> void:
    var main := preload("res://scenes/main.tscn").instantiate()
    suite.root.add_child(main)
    suite._check(main.column.get_node("Title").text == main.presentation.title, "reskin menu uses theme title")
    main.start_run()
    var player: CharacterBody2D = main.run.get_node("Player")
    player.set_physics_process(false)
    var rack: Node = player.get_node("WeaponRack")
    rack.set_physics_process(false)
    main.run.get_node("SpawnDirector").next_spawn = INF
    var visual: Node2D = player.get_node("Visual").get_child(0)
    suite._check(visual.scene_file_path == main.content.character.visual_scene, "reskin loads actor visual path")
    suite._check(visual.modulate == main.presentation.player_color, "reskin actor uses theme tint")
    suite._check(main.run.get_node("Player/Label").text == main.content.character.display_name, "reskin actor uses data name")
    suite._check(is_equal_approx(player.get_node("CollisionShape2D").shape.radius, 10), "reskin leaves body radius intact")
    suite._check(player.collision_layer == 2 and player.collision_mask == 1, "reskin preserves player collision layers")
    suite._check(player.speed == main.content.character.speed, "reskin preserves data movement speed")
    rack._physics_process(main.content.weapons[0].cadence)
    var shot: Node = main.run.get_node("Attacks").get_child(0)
    suite._check(is_equal_approx(shot.remaining, main.content.weapons[0].lifetime), "weapon lifetime tuning reaches live projectile")
    suite._check(shot.weapon == main.content.weapons[0], "reskin uses original weapon contract")
    main.retry_run()
    suite._check(main.run.get_node("Player/Visual").get_child(0).scene_file_path == main.content.character.visual_scene, "retry retains reskinned visual")
    suite._check(main.run.get_node("Player/Health").current == main.content.character.max_health and main.run.elapsed == 0, "reskin retry resets health and timer")
    main.queue_free()
    await suite.process_frame
