extends SceneTree
## Real receiver/pickup scenes, attack windows, pause and whole-run replacement.

const MAIN = preload("res://main.tscn")
var run: Node
var checks: int = 0
var failures: int = 0
var breaks: int = 0
var collections: int = 0
var health_events: int = 0


func _initialize() -> void:
	_test.call_deferred()


func _test() -> void:
	run = MAIN.instantiate()
	root.add_child(run)
	run.start_run()
	await _frames(2)
	var street: Node2D = run.street
	var hero: CharacterBody2D = street.player
	var prop: Node2D = street.get_node("Actors/RecoveryProp")
	hero.set_physics_process(false)
	street.set_physics_process(false)
	prop.broken.connect(func() -> void:
		breaks += 1
		prop.receive_hit(999, Vector2.RIGHT))
	_check(prop.position == Vector2(1280, 278) and prop.health == 20,
		"one recovery prop sits on the connecting stretch")
	_check(not prop is CollisionObject2D, "prop does not block movement")
	_check(prop.is_in_group("damage_receivers") and prop.team != hero.team,
		"prop participates in player's existing damage path")
	_check(not prop.receive_hit(0, Vector2.RIGHT) and not prop.receive_hit(-2, Vector2.RIGHT),
		"invalid damage cannot break or heal prop")
	var enemy: CharacterBody2D = load("res://scenes/enemies/grunt.tscn").instantiate()
	street.get_node("Actors").add_child(enemy)
	enemy.set_physics_process(false)
	enemy.position = prop.position - Vector2(40, 0)
	enemy.strike_targets(1, 60, 14, 8, 999, true, {})
	_check(prop.health == 20, "enemy strikes cannot destroy recovery prop")
	enemy.queue_free()
	var hits: Dictionary = {}
	hero.position = prop.position - Vector2(40, 0)
	hero.strike_targets(-1, 52, 14, 8, 10, false, hits)
	_check(prop.health == 20, "wrong facing misses prop")
	hero.position = prop.position - Vector2(53, 0)
	hero.strike_targets(1, 52, 14, 8, 10, false, hits)
	_check(prop.health == 20, "out of reach misses prop")
	hero.position = prop.position - Vector2(40, 15)
	hero.strike_targets(1, 52, 14, 8, 10, false, hits)
	_check(prop.health == 20, "wrong depth misses prop")
	hero.position = prop.position - Vector2(40, 0)
	hero.jump_height = 9
	hero.strike_targets(1, 52, 14, 8, 10, false, hits)
	_check(prop.health == 20, "ground strike above height band misses prop")
	hero.jump_height = 0
	hero.press_attack()
	hero._tick_attack(0.2)
	_check(prop.health == 20, "windup cannot damage prop")
	hero._tick_attack(0.05)
	hero._tick_attack(0.01)
	_check(prop.health == 10 and not prop.is_broken, "active strike damages prop once")
	hero._tick_attack(0.2)
	hero.press_attack()
	hero._tick_attack(0.25)
	_check(prop.is_broken and prop.health == 0 and breaks == 1,
		"second strike breaks once even with reentrant damage")
	_check(not prop.receive_hit(999, Vector2.RIGHT, true), "broken prop rejects later hits")
	_check(not prop.get_node("Intact").visible and prop.get_node("Debris").visible,
		"broken state shows debris instead of intact crate")
	_check(get_nodes_in_group("food_pickups").size() == 1, "exactly one deterministic drop")
	var food: Node2D = get_nodes_in_group("food_pickups")[0]
	food.set_physics_process(false)
	food.collected.connect(func() -> void: collections += 1)
	_check(food.position == prop.position + Vector2(32, 0) and food.player == hero,
		"drop has reachable ground position and hero receiver")
	hero.cancel_attack()
	hero.position = food.position
	_check(not food.try_collect() and hero.health == 100 and not food.is_collected,
		"full health leaves food available")
	hero.health = 50
	hero.position.x += 23
	_check(not food.try_collect() and hero.health == 50, "distant hero cannot collect")
	hero.position = food.position + Vector2(0, 13)
	_check(not food.try_collect() and hero.health == 50, "different depth lane cannot collect")
	hero.position = food.position
	hero.jump_height = 1
	_check(not food.try_collect(), "airborne hero cannot collect")
	hero.jump_height = 0
	hero._jump_velocity = 260
	_check(not food.try_collect(), "jump initiation cannot collect before visual rises")
	hero._jump_velocity = 0
	hero.health = 0
	hero.reaction = hero.Reaction.DEAD
	_check(not food.try_collect() and hero.health == 0, "dead hero cannot collect or revive")
	hero.health = 90
	hero.reaction = hero.Reaction.READY
	hero.health_changed.connect(func(_value: int) -> void:
		health_events += 1
		food.try_collect())
	_check(food.try_collect() and hero.health == 100, "food heals missing health and clamps at maximum")
	_check(not food.try_collect() and collections == 1 and health_events == 1,
		"collection and health signal happen once, including reentrant callback")
	await _frames(1)
	_check(get_nodes_in_group("food_pickups").is_empty(), "consumed food leaves scene")
	# Fresh runs exercise unconsumed drops under each result/menu replacement.
	for state in [run.State.PAUSED, run.State.DEAD, run.State.VICTORY]:
		run.start_run()
		await _frames(1)
		street = run.street
		hero = street.player
		prop = street.get_node("Actors/RecoveryProp")
		hero.set_physics_process(false)
		street.set_physics_process(false)
		prop.receive_hit(20, Vector2.RIGHT)
		food = get_nodes_in_group("food_pickups")[0]
		hero.health = 40
		hero.position = food.position
		run._show_menu(state)
		await _frames(3)
		_check(hero.health == 40 and not food.is_collected, "paused/result run freezes pickup %d" % state)
		if state == run.State.PAUSED:
			run.resume_run()
			await _frames(2)
			_check(hero.health == 70 and get_nodes_in_group("food_pickups").is_empty(),
				"resume collects with configured recovery and updates health")
			# Leave another unconsumed drop for paused Retry.
			run.start_run()
			await _frames(1)
			prop = run.street.get_node("Actors/RecoveryProp")
			prop.receive_hit(20, Vector2.RIGHT)
			run._show_menu(state)
		run.start_run()
		await _frames(1)
		prop = run.street.get_node("Actors/RecoveryProp")
		_check(not prop.is_broken and prop.health == 20 and get_nodes_in_group("food_pickups").is_empty(),
			"Retry/Play Again restores prop and removes old food %d" % state)
		_check(run.street.player.health == 100 and run.street.player.position == Vector2(160, 278),
			"reset retains full health and route start %d" % state)
	prop.receive_hit(20, Vector2.RIGHT)
	run.main_menu()
	await _frames(1)
	_check(get_nodes_in_group("food_pickups").is_empty() and get_nodes_in_group("damage_receivers").is_empty(),
		"Main Menu removes all props, drops and actors")
	print("Props checks: %d passed, %d failed" % [checks - failures, failures])
	run.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
