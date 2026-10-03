extends SceneTree
## Exercise the alternate art through the unchanged grunt and damage logic.

const STREET = preload("res://scenes/sample/art_swap_street.tscn")
var street: Node2D
var player: CharacterBody2D
var alternate: CharacterBody2D
var checks: int = 0
var failures: int = 0
var deaths: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	street = STREET.instantiate()
	root.add_child(street)
	current_scene = street
	await physics_frame
	await process_frame
	player = street.player
	alternate = street.enemies[0]
	player.set_physics_process(false)
	for enemy in street.enemies:
		enemy.set_physics_process(false)
	street.reset_test()
	var original: CharacterBody2D = street.enemies[1]
	_check(alternate.get_script() == original.get_script(), "swap keeps the ordinary enemy script")
	for property in ["max_health", "move_speed", "strike_times", "strike_damage",
			"strike_reach", "depth_tolerance", "knocks_down", "ground_bounds",
			"hurt_duration", "down_duration", "get_up_duration"]:
		_check(alternate.get(property) == original.get(property), "unchanged tuning: " + property)
	_check(alternate.sprite.sprite_frames.resource_path == "res://scenes/enemies/bruiser_frames.tres"
		and original.sprite.sprite_frames.resource_path == "res://scenes/enemies/grunt_frames.tres",
		"only left grunt uses the alternate art")
	_check(alternate.sprite.offset == Vector2(-14, -48)
		and alternate.visual.scale.abs() == Vector2(2, 2), "Cyborg feet offset and scale")
	_check(street.get_node("Actors").y_sort_enabled and alternate.visual.position == Vector2.ZERO,
		"depth sorting uses grounded roots")
	for animation in [&"idle", &"move", &"attack", &"hurt", &"fall", &"get_up"]:
		_check(alternate.sprite.sprite_frames.has_animation(animation), "semantic animation: " + animation)
	alternate.cooldown = 1.0
	var before := alternate.position
	alternate._physics_process(1.0 / 60.0)
	_check(alternate.position != before and alternate.sprite.animation == &"move",
		"alternate approaches using unchanged movement")
	_check(alternate.visual.scale.x < 0.0, "approach faces hero with source right-facing art")
	for offset in [Vector2(35, 0), Vector2(-35, 0), Vector2(35, 20)]:
		street.reset_test()
		alternate.position = Vector2(300, 278)
		player.position = alternate.position + offset
		alternate._attack_facing = 1.0
		alternate.attack_time = 0.0
		street.claim_slot(alternate)
		alternate._tick_attack(0.2)
		_check(player.health == 100 and alternate.sprite.frame < 4, "tell has no damage")
		alternate._tick_attack(0.21)
		_check(player.health == (88 if offset == Vector2(35, 0) else 100)
			and alternate.sprite.frame == 4, "contact respects facing and depth: " + str(offset))
		alternate._tick_attack(0.02)
		_check(player.health >= 88, "same strike cannot hit twice")
		alternate._tick_attack(0.1)
		_check(alternate.sprite.frame == 5, "recovery pose follows contact")
	street.reset_test()
	alternate.position = player.position - Vector2(35, 0)
	player.jump_height = 9.0
	alternate._attack_facing = 1.0
	alternate.attack_time = 0.0
	alternate._tick_attack(0.41)
	_check(player.health == 100, "alternate strike misses hero above ground hit band")
	street.reset_test()
	alternate.position = player.position + Vector2(35, 0)
	player.press_attack()
	player._tick_attack(0.25)
	alternate.update_reaction_visual()
	_check(alternate.health == 50 and alternate.sprite.animation == &"hurt",
		"player strike uses shared receiver and alternate hurt art")
	alternate.tick_reaction(0.25)
	alternate.receive_hit(1, Vector2.RIGHT, true)
	alternate.update_reaction_visual()
	_check(alternate.sprite.animation == &"fall" and alternate.reaction == alternate.Reaction.DOWN,
		"knockdown uses intact Cyborg fall frames")
	alternate.tick_reaction(0.76)
	alternate.update_reaction_visual()
	_check(alternate.sprite.animation == &"get_up", "recovery maps reverse fall frames")
	alternate.tick_reaction(0.31)
	_check(alternate.reaction == alternate.Reaction.READY, "alternate returns to ready")
	alternate.invulnerability = 0.0
	alternate.died.connect(func(): deaths += 1)
	alternate.receive_hit(1000, Vector2.RIGHT)
	alternate.tick_reaction(0.31)
	alternate.update_reaction_visual()
	_check(alternate.health == 0 and alternate.sprite.animation == &"fall"
		and alternate.sprite.frame == 3, "death holds intact last fall frame")
	alternate.receive_hit(1000, Vector2.RIGHT)
	_check(deaths == 1 and not street.slots.has(alternate), "death fires once and releases commitment")
	street.reset_test()
	_check(alternate.health == 60 and alternate.reaction == alternate.Reaction.READY
		and alternate.sprite.animation == &"idle" and alternate.position == alternate._spawn_position,
		"retry restores grunt rules with alternate idle art")
	print("Art swap checks: %d passed, %d failed" % [checks - failures, failures])
	street.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
