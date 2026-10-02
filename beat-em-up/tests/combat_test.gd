extends SceneTree
## Deterministic combat plus mapped input/pause regressions, without external runner.

const STREET = preload("res://scenes/combat/combat_street.tscn")
const DUMMY = preload("res://scenes/combat/dummy.tscn")
var _checks: int = 0
var _failures: int = 0
var _deaths: int = 0
var street: Node2D
var player: CharacterBody2D
var dummy: CharacterBody2D
var second: CharacterBody2D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	street = STREET.instantiate()
	root.add_child(street)
	current_scene = street
	player = street.get_node("Actors/Player")
	dummy = street.get_node("Actors/Dummy")
	second = DUMMY.instantiate()
	street.get_node("Actors").add_child(second)
	await _frames(3)
	player.set_physics_process(false)
	dummy.set_physics_process(false)
	second.set_physics_process(false)
	_clean()
	player.press_attack()
	player._tick_attack(0.2)
	_check(dummy.health == 120, "windup cannot damage")
	player._tick_attack(0.05)
	_check(dummy.health == 110 and second.health == 110, "one strike hits multiple targets")
	player._tick_attack(0.02)
	_check(dummy.health == 110, "same target takes only one hit")
	player._update_visual()
	_check(player.sprite.frame == 4, "first strike contact pose matches active window")
	player._tick_attack(0.06)
	second.invulnerability = 0.0
	second.health = 120
	player._tick_attack(0.02)
	_check(second.health == 120, "recovery cannot damage")

	for offset in [Vector2(-20, 0), Vector2(53, 0), Vector2(20, 15)]:
		_clean()
		dummy.position = player.position + offset
		player.press_attack()
		player._tick_attack(0.25)
		_check(dummy.health == 120, "reject behind/reach/depth: " + str(offset))
	_clean()
	dummy.jump_height = 9.0
	player.press_attack()
	player._tick_attack(0.25)
	_check(dummy.health == 120, "ground strike misses raised target")
	_clean()
	dummy.invulnerability = 0.02
	player.press_attack()
	player._tick_attack(0.25)
	dummy.tick_reaction(0.03)
	player._tick_attack(0.02)
	_check(dummy.health == 120, "protected target is registered once even after protection expires")
	_clean()
	dummy.team = player.team
	player.press_attack()
	player._tick_attack(0.25)
	_check(dummy.health == 120, "same-team actors cannot damage each other")
	dummy.team = 1
	_clean()
	player._facing = -1.0
	dummy.position.x = player.position.x - 35
	player.press_attack()
	player._facing = 1.0
	player._tick_attack(0.25)
	_check(dummy.health == 110, "strike commits facing independently of later input")

	_clean()
	player.press_attack()
	player.press_attack()
	player._tick_attack(0.41)
	_check(player.strike == -1, "early spam does not queue a combo")
	for index in range(3):
		if index == 0:
			player.press_attack()
		_check(player.strike == index, "deliberate combo strike %d" % (index + 1))
		player.attack_time = player.strike_times[index].x + 0.01
		player._update_visual()
		_check(player.sprite.frame == [4, 2, 4][index], "combo contact frame matches active phase")
		player.attack_time = 0.0
		var timing: Vector3 = player.strike_times[index]
		player._tick_attack(timing.x + timing.y)
		player.press_attack()
		player.press_attack()
		player._tick_attack(timing.z + 0.001)
	_check(player.strike == -1, "finisher cannot loop or queue a fourth strike")
	player.press_attack()
	_check(player.strike == 0, "late press starts fresh combo")
	player._tick_attack(0.21)
	player.press_attack()
	player._queued_time = 0.001
	player._tick_attack(0.2)
	_check(player.strike == -1, "expired buffer cannot advance")

	_clean()
	player.jump_height = 29.0
	player.press_attack()
	player._tick_attack(0.13)
	_check(dummy.health == 120, "air attack misses above low-height band")
	player.jump_height = 20.0
	player._tick_attack(0.02)
	_check(dummy.health == 105, "air attack hits in low-height band")
	player.cancel_attack()
	player.press_attack()
	_check(player.strike == -1, "one air attack per jump")
	player.jump_height = 1.0
	player._jump_velocity = -50.0
	player.strike = 3
	player._physics_process(0.1)
	_check(player.strike == -1 and player.jump_height == 0.0, "landing cancels air attack")
	player.press_attack()
	_check(player.strike == 0, "landing restores ground attack")

	_clean()
	player.press_attack()
	for index in range(3):
		while player.strike == index:
			var timing: Vector3 = player.strike_times[index]
			if player.attack_time >= timing.x + timing.y:
				player.press_attack()
			player._tick_attack(1.0 / 60.0)
			dummy.tick_reaction(1.0 / 60.0)
	_check(dummy.health == 80 and dummy.reaction == dummy.Reaction.DOWN,
		"all three combo hits connect through hurt and knockback")
	_clean()
	player._start_strike(2)
	player._tick_attack(0.25)
	_check(dummy.reaction == dummy.Reaction.DOWN and dummy.health == 102, "finisher knocks down")
	_check(not dummy.receive_hit(10, Vector2.RIGHT), "downed actor rejects ground damage")
	dummy.tick_reaction(0.8)
	_check(dummy.reaction == dummy.Reaction.GET_UP, "knockdown advances to get-up")
	_check(not dummy.receive_hit(10, Vector2.RIGHT), "get-up is protected")
	dummy.tick_reaction(0.31)
	_check(dummy.reaction == dummy.Reaction.READY and dummy.invulnerability > 0.0,
		"get-up finishes with short protection")
	dummy.tick_reaction(0.21)
	_check(dummy.receive_hit(1, Vector2.LEFT), "recovered actor can be hit again")

	_clean()
	player.press_attack()
	player._tick_attack(0.3)
	player.press_attack()
	player.receive_hit(15, Vector2.LEFT)
	_check(player.health == 85 and player.strike == -1 and player._queued_time == 0.0,
		"hurt interrupts and clears queued attack")
	_check(not player.receive_hit(15, Vector2.LEFT), "hurt invulnerability rejects repeat damage")
	player.position = player.ground_bounds.position
	player.tick_reaction(0.1)
	_check(player.position == player.ground_bounds.position, "knockback obeys ground bounds")
	street.reset_test()
	_check(player.health == 100 and player.reaction == player.Reaction.READY \
		and player.invulnerability == 0.0 and player._hit_targets.is_empty(), "reset while hurt clears state")

	_clean()
	player.jump_height = 30.0
	player._jump_velocity = 60.0
	player.press_attack()
	player.receive_hit(10, Vector2.RIGHT)
	_check(player.strike == -1 and player.reaction == player.Reaction.DOWN, "air hurt cancels attack")
	for index in range(100):
		player.tick_reaction(1.0 / 60.0)
	_check(player.jump_height == 0.0 and player.reaction == player.Reaction.READY,
		"air hurt lands and recovers without stuck state")

	_clean()
	player.died.connect(func(): _deaths += 1)
	player.press_attack()
	player.receive_hit(1000, Vector2.RIGHT)
	player.receive_hit(1000, Vector2.RIGHT)
	player.press_attack()
	_check(player.health == 0 and _deaths == 1 and player.strike == -1, "health clamps, death emits once, attacks stop")
	street.reset_test()
	_check(player.health == 100 and dummy.health == 120, "reset restores both actors")
	_check(not player.receive_hit(-1, Vector2.ZERO), "negative damage is rejected")

	# Mapped input and real scene pause: held attack is never an automatic combo.
	player.set_physics_process(true)
	dummy.set_physics_process(true)
	await _frames(3)
	_key(KEY_J, true)
	await _frames(35)
	_check(player.strike == -1, "holding mapped J does not repeat or auto-combo")
	_key(KEY_J, false)
	await _frames(2)
	_button(JOY_BUTTON_X, true)
	await _frames(2)
	_check(player.strike == 0, "mapped west button starts attack")
	_button(JOY_BUTTON_X, false)
	await _frames(30)
	for elapsed in [0.05, 0.25, 0.35]:
		_clean()
		player.press_attack()
		player.attack_time = elapsed
		street.toggle_pause()
		var saved: float = player.attack_time
		var hp: int = dummy.health
		var protection: float = player.invulnerability
		var pose: int = player.sprite.frame
		await _frames(8)
		_check(player.invulnerability == protection and player.sprite.frame == pose, "pause freezes protection and sprite")
		_check(player.attack_time == saved and dummy.health == hp, "pause freezes phase %.2f" % elapsed)
		_key(KEY_ENTER, true)
		await _frames(2)
		_check(not paused and player._queued_time == 0.0, "resume cannot queue attack through confirm")
		_key(KEY_ENTER, false)
		await _frames(30)
	_clean()
	player.position = Vector2(380, 278)
	dummy.position = Vector2(420, 278)
	_key(KEY_K, true)
	await _frames(28)
	_check(player.health == 85, "controlled mapped dummy strike reaches player")
	_key(KEY_K, false)
	street.toggle_pause()
	street.reset_test()
	_check(not paused and dummy.incoming_time < 0.0 and player.health == 100,
		"paused reset cancels incoming attack and restores health")
	await _frames(3)
	player.position = Vector2(380, 278)
	dummy.position = Vector2(420, 278)
	_key(KEY_L, true)
	await _frames(28)
	_check(player.reaction == player.Reaction.DOWN, "controlled knockdown input produces down reaction")
	_key(KEY_L, false)
	street.reset_test()
	await _frames(3)
	player.position = dummy.position
	await _frames(12)
	_check(player.health == 100, "body contact does no damage")
	print("Combat checks: %d passed, %d failed" % [_checks - _failures, _failures])
	street.queue_free()
	await process_frame
	quit(0 if _failures == 0 else 1)


func _clean() -> void:
	street.reset_test()
	player._waiting_for_release = false
	dummy.position = player.position + Vector2(35, 0)
	second.reset()
	second.position = player.position + Vector2(40, 2)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
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
