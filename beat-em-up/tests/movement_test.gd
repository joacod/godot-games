extends SceneTree
## Run with --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd.

const STREET = preload("res://main.tscn")
const MOVE_ACTIONS = ["move_left", "move_right", "move_up", "move_down"]

var _checks: int = 0
var _failures: int = 0
var _street: Node2D
var _player: CharacterBody2D
var _camera: Camera2D
var _sprite: AnimatedSprite2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_street = STREET.instantiate()
	root.add_child(_street)
	current_scene = _street
	_player = _street.get_node("Actors/Player")
	_camera = _street.get_node("Camera")
	_sprite = _player.get_node("Visual/Sprite")
	await _frames(3)
	_check(_street.get_node("Actors").y_sort_enabled, "actor sorting uses ground roots")
	_check(_player.get_node("Footprint").position == Vector2.ZERO, "footprint stays at feet")
	_check(InputMap.action_get_deadzone("move_left") == 0.25, "movement deadzone configured")

	# Equal travel distance across a cardinal direction and a diagonal.
	var start := _player.position
	Input.action_press("move_right")
	await _frames(12)
	var cardinal_distance := _player.position.distance_to(start)
	_release_movement()
	_street.reset_test()
	await _frames(3)
	start = _player.position
	Input.action_press("move_right")
	Input.action_press("move_down")
	await _frames(12)
	var diagonal_distance := _player.position.distance_to(start)
	_check(cardinal_distance > 0.0, "movement advances player")
	_check(absf(cardinal_distance - diagonal_distance) < 0.1, "diagonals are not faster")
	_release_movement()
	await _frames(2)
	_check(_sprite.animation == &"idle", "release returns to idle")

	# Facing follows horizontal input, then persists through vertical movement.
	Input.action_press("move_left")
	await _frames(2)
	_release_movement()
	Input.action_press("move_up")
	await _frames(2)
	_check(_player.get_node("Visual").scale.x < 0.0, "vertical travel preserves left facing")
	_release_movement()

	# Use mapped stick events to exercise the deadzone without claiming hardware QA.
	_street.reset_test()
	await _frames(3)
	start = _player.position
	_stick(0.1)
	await _frames(6)
	_check(_player.position == start, "stick below deadzone does not drift")
	_stick(0.8)
	await _frames(6)
	_check(_player.position.x > start.x, "stick above deadzone moves")
	_stick(0.0)
	await _frames(3)

	# All four boundaries are authoritative even while airborne.
	for action in MOVE_ACTIONS:
		_street.reset_test()
		await _frames(3)
		var edge: Vector2 = _player.ground_bounds.position
		if action == "move_right" or action == "move_down":
			edge = _player.ground_bounds.end
		_player.position = edge
		Input.action_press(action)
		Input.action_press("jump")
		await _frames(6)
		_check(_player.position == edge, "airborne boundary: " + action)
		_check(_player.jump_height > 0.0, "jump works at boundary: " + action)
		Input.action_release("jump")
		_release_movement()

	_street.reset_test()
	await _frames(3)
	start = _player.position
	Input.action_press("jump")
	await _frames(6)
	_check(_player.jump_height > 0.0, "jump raises height")
	_check(_player.position == start, "in-place jump keeps ground anchor")
	_check(is_equal_approx(_player.get_node("Visual").position.y, -_player.jump_height),
		"visual follows height")
	_check(_player.get_node("Shadow").position == Vector2.ZERO, "shadow stays grounded")
	_check(_sprite.animation == &"jump", "airborne presentation uses jump poses")
	Input.action_press("move_right")
	await _frames(3)
	_check(_player.position.x > start.x, "air movement remains available")
	_release_movement()
	Input.action_release("jump")

	# Exercise real mapped keyboard pause events, including repeat rejection.
	_key(KEY_ESCAPE, true)
	await _frames(2)
	_check(paused, "Escape pauses")
	_key(KEY_ESCAPE, true, true)
	await _frames(2)
	_check(paused, "key repeat does not toggle pause")
	_key(KEY_ESCAPE, false)
	var paused_height: float = _player.jump_height
	var paused_position := _player.position
	var paused_camera := _camera.position
	var paused_frame := _sprite.frame
	await _frames(12)
	_check(_player.jump_height == paused_height, "pause freezes jump height")
	_check(_player.position == paused_position, "pause freezes movement")
	_check(_camera.position == paused_camera, "pause freezes camera")
	_check(_sprite.frame == paused_frame, "pause freezes animation")
	Input.action_press("move_right")
	_key(KEY_ENTER, true)
	await _frames(3)
	_check(not paused, "Enter resumes")
	_check(_player.position == paused_position, "resume blocks held movement")
	_check(_player.jump_height != paused_height, "resumed jump continues despite input guard")
	_key(KEY_ENTER, false)
	_release_movement()
	await _frames(60)
	_check(_player.jump_height == 0.0, "jump lands at zero height")
	_check(_player.get_node("Visual").position.y == 0.0, "visual returns to ground anchor")

	# Holding jump does not automatically bounce after landing.
	Input.action_press("jump")
	await _frames(80)
	_check(_player.jump_height == 0.0, "held jump does not repeat")
	Input.action_release("jump")
	await _frames(3)
	Input.action_press("jump")
	Input.action_press("move_left")
	await _frames(6)
	_key(KEY_R, true)
	await _frames(3)
	_check(_player.position == start, "midair reset restores spawn")
	_check(_player.jump_height == 0.0, "midair reset clears height")
	_check(_player.velocity == Vector2.ZERO, "reset clears velocity")
	_check(_player.get_node("Visual").scale.x > 0.0, "reset restores facing")
	_check(_camera.position == Vector2(320, 180), "reset restores camera")
	_check(_player.jump_height == 0.0, "held jump cannot leak through reset")
	_key(KEY_R, false)
	_release_movement()
	Input.action_release("jump")
	await _frames(3)
	Input.action_press("move_right")
	await _frames(3)
	_check(_player.position.x > start.x, "fresh movement works after reset")
	_release_movement()

	# Camera follows street length only, clamped to both viewport endpoints.
	_player.position = Vector2(700, 300)
	await _frames(2)
	_check(_camera.position == Vector2(700, 180), "camera follows X and ignores depth")
	_player.position.x = 1232
	await _frames(2)
	_check(_camera.position.x == 960.0, "camera clamps at right edge")
	_player.position.x = 48
	await _frames(2)
	_check(_camera.position.x == 320.0, "camera clamps at left edge")

	# South-button confirmation resumes without also jumping; west resets while paused.
	_key(KEY_ESCAPE, true)
	await _frames(2)
	_key(KEY_ESCAPE, false)
	_button(JOY_BUTTON_A, true)
	await _frames(3)
	_check(not paused and _player.jump_height == 0.0, "south resume cannot leak jump")
	_button(JOY_BUTTON_A, false)
	await _frames(3)
	_button(JOY_BUTTON_A, true)
	await _frames(6)
	_check(_player.jump_height > 0.0, "fresh south press jumps")
	_button(JOY_BUTTON_A, false)
	_key(KEY_ESCAPE, true)
	await _frames(2)
	_key(KEY_ESCAPE, false)
	_button(JOY_BUTTON_X, true)
	await _frames(3)
	_check(not paused and _player.position == start and _player.jump_height == 0.0,
		"west resets a paused jump")
	_button(JOY_BUTTON_X, false)
	await _frames(3)

	print("Movement checks: %d passed, %d failed" % [_checks - _failures, _failures])
	_street.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _key(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)


func _stick(value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X
	event.axis_value = value
	Input.parse_input_event(event)


func _button(index: JoyButton, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = pressed
	Input.parse_input_event(event)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(description)
