extends "res://scripts/combat_actor.gd"
## Ground root, raised jump visual, and a deliberately bounded three-strike combo.

@export var move_speed: float = 130.0
@export var jump_speed: float = 260.0
@export var strike_times: Array[Vector3] = [Vector3(0.24, 0.08, 0.08),
	Vector3(0.16, 0.08, 0.08), Vector3(0.24, 0.06, 0.12), Vector3(0.12, 0.12, 0.18)]
@export var strike_damage: Array[int] = [10, 12, 18, 15]
@export var strike_reach: Array[float] = [52.0, 56.0, 64.0, 64.0]
@export var depth_tolerance: float = 14.0
@export var ground_hit_height: float = 8.0
@export var air_hit_height: float = 28.0
@export var combo_buffer: float = 0.22

var strike: int = -1
var attack_time: float = 0.0
var _queued_time: float = 0.0
var _attack_facing: float = 1.0
var _hit_targets: Dictionary = {}
var _air_attack_used: bool = false
var _waiting_for_release: bool = true


func _ready() -> void:
	super._ready()
	_update_visual()


func _physics_process(delta: float) -> void:
	if _waiting_for_release:
		_waiting_for_release = Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO \
				or Input.is_action_pressed("jump") or Input.is_action_pressed("attack") \
				or Input.is_action_pressed("ui_accept") or Input.is_action_pressed("pause") \
				or Input.is_action_pressed("test_reset")
	tick_reaction(delta)
	if reaction != Reaction.READY:
		update_reaction_visual()
		return
	if not _waiting_for_release:
		if Input.is_action_just_pressed("jump") and jump_height == 0.0 and strike < 0:
			_jump_velocity = jump_speed
		if Input.is_action_just_pressed("attack"):
			press_attack()
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _waiting_for_release or strike >= 0:
		direction = Vector2.ZERO
	velocity = direction * move_speed
	move_and_slide()
	position = position.clamp(ground_bounds.position, ground_bounds.end)
	if not is_zero_approx(direction.x):
		_facing = signf(direction.x)
	if _jump_velocity > 0.0 or jump_height > 0.0:
		_jump_velocity -= jump_gravity * delta
		jump_height = maxf(0.0, jump_height + _jump_velocity * delta)
		if jump_height == 0.0:
			_jump_velocity = 0.0
			_air_attack_used = false
			if strike == 3:
				cancel_attack()
	_tick_attack(delta)
	_update_visual()


func press_attack() -> void:
	if reaction != Reaction.READY:
		return
	if strike >= 0:
		var timing := strike_times[strike]
		var remaining := timing.x + timing.y + timing.z - attack_time
		if strike < 2 and remaining <= combo_buffer:
			_queued_time = combo_buffer
		return
	if jump_height > 0.0 or _jump_velocity > 0.0:
		if not _air_attack_used:
			_air_attack_used = true
			_start_strike(3)
	else:
		_start_strike(0)


func _start_strike(index: int) -> void:
	strike = index
	attack_time = 0.0
	_queued_time = 0.0
	_hit_targets.clear()
	_attack_facing = _facing
	velocity = Vector2.ZERO
	attack_started.emit()


func _tick_attack(delta: float) -> void:
	if strike < 0:
		return
	_queued_time = maxf(0.0, _queued_time - delta)
	attack_time += delta
	var timing := strike_times[strike]
	if attack_time >= timing.x and attack_time < timing.x + timing.y:
		strike_targets(_attack_facing, strike_reach[strike], depth_tolerance,
			air_hit_height if strike == 3 else ground_hit_height,
			strike_damage[strike], strike == 2, _hit_targets)
	if attack_time >= timing.x + timing.y + timing.z:
		if _queued_time > 0.0 and strike < 2:
			_start_strike(strike + 1)
		else:
			cancel_attack()


func cancel_attack() -> void:
	strike = -1
	attack_time = 0.0
	_queued_time = 0.0
	_hit_targets.clear()


func require_input_release() -> void:
	_waiting_for_release = true
	velocity = Vector2.ZERO


func restore_health(amount: int) -> int:
	if amount <= 0 or health <= 0 or jump_height > 0.0 or _jump_velocity > 0.0:
		return 0
	var restored := mini(amount, max_health - health)
	if restored <= 0:
		return 0
	health += restored
	health_changed.emit(health)
	return restored


func reset() -> void:
	super.reset()
	_air_attack_used = false
	require_input_release()
	sprite.stop()
	_update_visual()


func _update_visual() -> void:
	update_reaction_visual()
	if reaction != Reaction.READY:
		return
	if strike >= 0:
		visual.scale.x = absf(visual.scale.x) * _attack_facing
		sprite.animation = [&"attack_1", &"attack_2", &"attack_3", &"air_attack"][strike]
		sprite.pause()
		var timing := strike_times[strike]
		var contact: int = [4, 2, 4, 2][strike]
		var last := sprite.sprite_frames.get_frame_count(sprite.animation) - 1
		if attack_time < timing.x:
			sprite.frame = mini(contact - 1, int(attack_time / timing.x * contact))
		elif attack_time < timing.x + timing.y:
			sprite.frame = contact
		else:
			sprite.frame = mini(last, contact + 1)
	elif jump_height > 0.0:
		sprite.animation = &"jump"
		sprite.pause()
		sprite.frame = 1 if _jump_velocity > 60.0 else (2 if _jump_velocity >= -60.0 else 3)
	else:
		sprite.play(&"move" if velocity.length_squared() > 0.0 else &"idle")
