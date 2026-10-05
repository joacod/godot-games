extends SceneTree

const Validator = preload("res://scripts/content/content_validator.gd")
const MAIN = preload("res://scenes/main.tscn")
var passed := 0
var failed := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    create_timer(15.0).timeout.connect(func():
        push_error("Test runner timed out")
        quit(1)
    )
    var content := load("res://data/run.tres") as SurvivorRunData
    var theme := load("res://data/theme.tres") as SurvivorThemeData
    _check(Validator.validate(content, theme).is_empty(), "shipped content validates")
    _invalid(content, theme, "character", null, "character: required")
    var fixture := content.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as SurvivorRunData
    _invalid(fixture.character, theme, "visual_scene", "res://scenes/absent.tscn", "character.visual_scene", fixture)
    _invalid(fixture.character, theme, "visual_scene", "../outside.tscn", "project-local", fixture)
    _invalid(fixture.character, theme, "id", &"", "character.id", fixture)
    _invalid(fixture.character, theme, "max_health", 0, "max_health", fixture)
    _invalid(fixture.character, theme, "speed", NAN, "speed", fixture)
    _invalid(fixture.weapons[1], theme, "id", fixture.weapons[0].id, "duplicate ID 'spark'", fixture)
    _invalid(fixture.weapons[1], theme, "behavior", 0, "behavior", fixture)
    _invalid(fixture.weapons[0], theme, "rank_damage", PackedFloat32Array([10]), "three ranks", fixture)
    _invalid(fixture.weapons[0], theme, "rank_damage", PackedFloat32Array([10, -1, 15]), "rank_damage", fixture)
    _invalid(fixture.weapons[0], theme, "cadence", 0, "cadence", fixture)
    _invalid(fixture.weapons[0], theme, "projectile_speed", 0, "projectile_speed", fixture)
    _invalid(fixture.weapons[1], theme, "radius", -1, "radius", fixture)
    _invalid(fixture.weapons[0], theme, "attack_scene", "res://data/run.tres", "attack_scene", fixture)
    _invalid(fixture, theme, "starting_weapon_id", &"absent", "starting_weapon_id")
    _invalid(fixture, theme, "duration", INF, "run.duration")
    _invalid(fixture, theme, "ordinary_cap", 0, "ordinary_cap")
    _invalid(fixture, theme, "arena_size", Vector2.ZERO, "arena_size")
    _invalid(fixture, theme, "first_level_xp", 0, "first_level_xp")
    _invalid(fixture, theme, "elite_spawn_seconds", 180, "elite_spawn_seconds")
    _invalid(fixture.enemies[1], theme, "elite", false, "ordinary must precede", fixture)
    _invalid(fixture.enemies[0], theme, "xp_reward", -5, "xp_reward", fixture)
    _invalid(fixture.upgrades[0], theme, "target_id", &"missing", "target", fixture)
    _invalid(fixture.upgrades[5], theme, "max_rank", 1, "uncapped", fixture)
    _invalid(fixture.upgrades[8], theme, "required_passive_id", &"missing", "recipe", fixture)
    _invalid(fixture.spawn_phases[0], theme, "start_seconds", 1, "start_seconds", fixture)
    _invalid(fixture.spawn_phases[1], theme, "interval", 0, "interval", fixture)
    _invalid(theme, theme, "arena_visual_scene", "res://scenes/arena.tscn", "physics", fixture)
    _check(not Validator.validate(content, null).is_empty(), "missing theme rejected")
    for field in ["weapons", "enemies", "upgrades", "spawn_phases"]:
        var saved: Array = fixture.get(field).duplicate()
        fixture.get(field).clear()
        _check(not Validator.validate(fixture, theme).is_empty(), "empty %s rejected" % field)
        fixture.get(field).assign(saved)
    _check(Validator.validate(content, theme).is_empty(), "negative fixtures did not mutate shipped assets")
    for action in ["move_left", "move_right", "move_up", "move_down", "confirm", "cancel", "pause"]:
        _check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "input declared: %s" % action)
    var main := MAIN.instantiate()
    root.add_child(main)
    await process_frame
    _check(main.run == null and main.menu.visible, "initial menu has no run")
    _check(main.column.get_node("Start").has_focus(), "Start has keyboard focus")
    main.content = fixture
    fixture.weapons[1].id = &"spark"
    _check(not main.start_run(), "invalid content blocks Start")
    _check(main.run == null and main.menu.visible, "invalid Start leaves menu available")
    _check("duplicate ID 'spark'" in main.column.get_node("Error").text, "Start shows actionable diagnostic")
    main.content = content
    _check(main.start_run(), "Start builds arena")
    await process_frame
    var first_run: Node = main.run
    _check(not main.menu.visible and main.arena_ui.visible, "Start swaps menu to arena UI")
    _check(not main.start_run(), "duplicate Start does not create second arena")
    _check(main.run == first_run, "duplicate Start preserves original run")
    _check(main.run.get_node("Player/Label").text == content.character.display_name, "character label comes from data")
    _check(main.run.get_node("Enemy/Label").text == content.enemies[0].display_name, "enemy label comes from data")
    var position_before: Vector2 = main.run.get_node("Player").position
    Input.action_press("move_right")
    await physics_frame
    await physics_frame
    Input.action_release("move_right")
    _check(main.run.get_node("Player").position.x > position_before.x, "player moves with input")
    # Visual replacement must not change actor collision dimensions.
    var player: CharacterBody2D = main.run.get_node("Player")
    var collision := player.get_node("CollisionShape2D") as CollisionShape2D
    var shape_before := collision.shape
    player.set_physics_process(false)
    player.get_node("Visual").free()
    _check(collision.shape == shape_before and is_equal_approx((collision.shape as CircleShape2D).radius, 10), "collision survives visual removal")
    for wall in ["Top", "Bottom", "Left", "Right"]:
        var boundary := main.run.get_node("Arena/Boundaries/" + wall) as CollisionShape2D
        _check(not boundary.disabled and boundary.shape is RectangleShape2D, "solid boundary: %s" % wall)
    # Exercise actual physical wall blocking.
    await physics_frame
    var origin := player.position
    for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
        player.position = origin
        var hit := player.move_and_collide(direction * 2000)
        _check(hit != null, "wall blocks test motion: %s" % direction)
        _check(player.position.x >= 10 and player.position.x <= 950 and player.position.y >= 10 and player.position.y <= 630, "wall keeps marker in arena: %s" % direction)
    main.return_to_menu()
    await process_frame
    _check(not is_instance_valid(first_run), "return frees old arena")
    _check(main.menu.visible and main.run == null, "return restores menu")
    _check(main.start_run(), "second Start builds fresh arena")
    _check(main.run.get_node("Player/Visual").get_child_count() == 1, "rebuilt arena restores visual")
    _check(Validator.validate(content, theme).is_empty(), "rebuilding does not mutate content")
    main.queue_free()
    await process_frame
    await preload("res://tests/movement_health_test.gd").new().run(self)
    print("Results: %d passed, %d failed" % [passed, failed])
    quit(1 if failed else 0)

func _invalid(resource: Resource, theme: SurvivorThemeData, field: String, value: Variant, message: String, run_content: SurvivorRunData = null) -> void:
    var original: Variant = resource.get(field)
    resource.set(field, value)
    var content := resource as SurvivorRunData if run_content == null else run_content
    var errors := Validator.validate(content, theme)
    _check(message in "\n".join(errors), "reject %s with actionable %s" % [field, message])
    resource.set(field, original)

func _check(condition: bool, label: String) -> void:
    if condition:
        passed += 1
    else:
        failed += 1
        push_error("FAIL: " + label)
