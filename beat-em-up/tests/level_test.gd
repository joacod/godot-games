extends SceneTree
## Real scene regressions for gates, queued waves and whole-run reset.

const MAIN = preload("res://main.tscn")
var run: Node
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_test.call_deferred()


func _test() -> void:
	run = MAIN.instantiate()
	root.add_child(run)
	await _frames(2)
	_check(run.state == run.State.TITLE and run.street == null, "boot offers title without a live run")
	await _tap(KEY_DOWN)
	await _tap(KEY_ENTER)
	_check(run.state == run.State.CONTROLS, "keyboard focus navigation opens Controls")
	_check(run.items.get_child(1).text.contains("D-pad"), "controls include controller bindings")
	await _tap(KEY_ESCAPE)
	_check(run.state == run.State.TITLE, "Escape returns from Controls")
	_key(KEY_ENTER, true)
	await _frames(2)
	_check(run.state == run.State.PLAYING and run.street.player.jump_height == 0.0 \
		and run.street.player._waiting_for_release, "held menu confirm cannot jump into gameplay")
	_key(KEY_ENTER, false)
	await _frames(2)
	var street: Node2D = run.street
	var hero: CharacterBody2D = street.player
	var first: Node2D = street.encounters[0]
	_check(hero.health == 100 and first.enemies.is_empty(), "safe entrance starts with full health and no enemies")
	hero.position = Vector2(535, 278)
	street._update_progress()
	_check(not first.started, "gate remains open until feet are safely inside")
	hero.jump_height = 30.0
	hero.position.x = 540
	street._update_progress()
	_stop(street)
	_check(first.started and first.living.size() == 2 and street.active == first, "airborne safe entry starts one fight")
	_check(hero.ground_bounds == first.arena_bounds and street.camera.position.x == 750, "arena locks movement and camera")
	for enemy in first.enemies:
		_check(enemy.position.distance_to(hero.position) >= 80.0 and first.is_visible_fighter(enemy) \
			and first.arena_bounds.has_point(enemy.position), "spawn is separated, visible and reachable")
	first.start()
	_check(first.enemies.size() == 2, "duplicate entry cannot spawn twice")
	hero.position.x = 10000
	hero._physics_process(0.0)
	_check(hero.position.x == first.arena_bounds.end.x, "jump cannot escape right gate")
	hero.position.x = -10000
	hero._physics_process(0.0)
	_check(hero.position.x == first.arena_bounds.position.x, "backtracking cannot escape left gate")
	_defeat(first)
	_check(first.finished and street.active == null and street.prompt == "GO →", "first clear unlocks and prompts forward")
	hero.position.x = 540
	street._update_progress()
	_check(first.enemies.size() == 2 and street.active == null, "cleared fight cannot retrigger")
	hero.position.x = 1620
	street._update_progress()
	var second: Node2D = street.encounters[1]
	_stop(street)
	_defeat(second)
	_check(not second.finished and second.next_wave == 1 and street.active == second, "queued second wave keeps gates locked")
	second._enemy_died(second.enemies[0])
	_check(second.pending_time == second.wave_delay and not second.finished, "duplicate death cannot advance wave")
	await _tap(KEY_ESCAPE)
	_check(run.state == run.State.PAUSED, "Escape opens the pause menu")
	var timer: float = second.pending_time
	await _frames(90)
	_check(second.pending_time == timer and second.enemies.size() == 2, "pause freezes scheduled wave")
	await _tap(KEY_ESCAPE)
	_check(run.state == run.State.PLAYING and not paused, "Escape resumes gameplay")
	second._physics_process(0.6)
	_check(second.enemies.size() == 2 and not second.finished, "wave delay retains lock")
	second._physics_process(0.6)
	_stop(street)
	_check(second.enemies.size() == 4 and second.living.size() == 2 \
		and second.enemies[3].knocks_down, "next wave spawns one grunt and bruiser")
	_defeat(second)
	_check(second.finished and street.active == null, "final scheduled enemies unlock second arena")
	hero.position.x = 2300
	street._update_progress()
	_check(street.reached_entrance and is_instance_valid(street.boss), "route reaches a locked boss arena")
	for encounter_index in [0, 1]:
		run.start_run()
		await _frames(1)
		street = run.street
		street.player.position.x = 540
		street._update_progress()
		if encounter_index == 1:
			_defeat(street.encounters[0])
			street.player.position.x = 1620
			street._update_progress()
		_stop(street)
		run._show_menu(run.State.PAUSED)
		run.start_run()
		await _frames(1)
		_check(_fresh(), "paused retry resets entire run from encounter %d" % encounter_index)
	# Die while the mixed fight is waiting to spawn its next wave.
	street = run.street
	street.player.position.x = 540
	street._update_progress()
	_defeat(street.encounters[0])
	street.player.position.x = 1620
	street._update_progress()
	_defeat(street.encounters[1])
	street.player.receive_hit(1000, Vector2.LEFT)
	await _frames(100)
	_check(run.state == run.State.DEAD and street.encounters[1].enemies.size() == 2,
		"death prevents pending spawns and opens Game Over")
	run.start_run()
	await _frames(1)
	_check(_fresh(), "death retry creates a clean run")
	run.main_menu()
	await _frames(1)
	_check(not paused and run.street == null and get_nodes_in_group("damage_receivers").is_empty(), "Main Menu discards all actors")
	var south := InputEventJoypadButton.new()
	south.device = 0
	south.button_index = JOY_BUTTON_A
	south.pressed = true
	Input.parse_input_event(south)
	await _frames(2)
	_check(_fresh(), "Main Menu to Play starts clean")
	_check(run.street.player.jump_height == 0.0 and run.street.player._waiting_for_release,
		"held controller confirm cannot leak into jump")
	south.pressed = false
	Input.parse_input_event(south)
	await _frames(2)
	_check(run.street.player._waiting_for_release or run.street.player.strike == -1, "menu confirmation does not start an attack")
	print("Level checks: %d passed, %d failed" % [checks - failures, failures])
	run.main_menu()
	run.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _fresh() -> bool:
	var street: Node2D = run.street
	return not paused and run.state == run.State.PLAYING and street.player.health == 100 \
		and street.player.position == Vector2(160, 278) and street.camera.position.x == 320 \
		and street.active == null and not street.reached_entrance \
		and not street.encounters[0].started and not street.encounters[1].started \
		and street.encounters[0].slots.is_empty() and street.encounters[1].enemies.is_empty()


func _stop(street: Node2D) -> void:
	street.player.set_physics_process(false)
	for encounter in street.encounters:
		for enemy in encounter.enemies:
			enemy.set_physics_process(false)


func _defeat(encounter: Node2D) -> void:
	for enemy in encounter.enemies:
		if enemy.health > 0:
			enemy.receive_hit(1000, Vector2.LEFT)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)


func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(code: Key) -> void:
	_key(code, true)
	await _frames(1)
	_key(code, false)
	await _frames(1)
