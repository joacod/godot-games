extends "res://scripts/combat_actor.gd"
## Two committed attacks on the ground plane; recovery always stays punishable.

signal defeat_finished

enum State { APPROACH, WINDUP, ACTIVE, RECOVERY }
enum Attack { SWEEP, CHARGE }

@export var move_speed: float = 65.0
@export var sweep_times: Vector3 = Vector3(0.55, 0.12, 0.9)
@export var charge_times: Vector3 = Vector3(0.85, 1.2, 1.1)
@export var sweep_reach: float = 72.0
@export var charge_reach: float = 40.0
@export var depth_tolerance: float = 14.0
@export var charge_speed: float = 310.0
@export var sweep_damage: int = 18
@export var charge_damage: int = 24
@export var death_duration: float = 0.9

var target: CharacterBody2D
var state: State = State.APPROACH
var attack: Attack = Attack.SWEEP
var next_attack: Attack = Attack.SWEEP
var attack_time: float = -1.0
var cooldown: float = 0.5
var _attack_facing: float = -1.0
var _charge_end: float
var _hit_targets: Dictionary = {}
var _hit_flash: float = 0.0
var _defeat_reported: bool = false


func _physics_process(delta: float) -> void:
	tick_reaction(delta)
	update_reaction_visual()
	_hit_flash = maxf(0.0, _hit_flash - delta)
	if reaction == Reaction.DEAD:
		sprite.frame = mini(5, int(reaction_time / death_duration * 6.0))
		if not _defeat_reported and reaction_time >= death_duration:
			_defeat_reported = true
			defeat_finished.emit()
		return
	if reaction != Reaction.READY:
		return
	if target == null or target.health == 0:
		cancel_attack()
		sprite.play(&"idle")
		return
	if attack_time >= 0.0:
		_tick_attack(delta)
	else:
		cooldown = maxf(0.0, cooldown - delta)
		var offset: Vector2 = target.position - position
		if absf(offset.x) > 2.0:
			_facing = signf(offset.x)
		if cooldown == 0.0 and absf(offset.y) <= depth_tolerance \
				and (next_attack == Attack.CHARGE or absf(offset.x) <= sweep_reach):
			_start_attack(next_attack)
		else:
			var destination: Vector2 = target.position - Vector2(_facing * 52.0, 0)
			var travel := destination - position
			velocity = travel.normalized() * minf(move_speed, travel.length() * 6.0)
			move_and_slide()
			position = position.clamp(ground_bounds.position, ground_bounds.end)
			visual.scale.x = absf(visual.scale.x) * _facing
			sprite.play(&"move" if velocity.length() > 2.0 else &"idle")
	sprite.modulate = Color(1, 0.5, 0.5) if _hit_flash > 0.0 else Color.WHITE
	queue_redraw()


func _start_attack(kind: Attack) -> void:
	attack = kind
	next_attack = Attack.CHARGE if kind == Attack.SWEEP else Attack.SWEEP
	state = State.WINDUP
	attack_time = 0.0
	_attack_facing = _facing
	_charge_end = clampf(position.x + _attack_facing * charge_speed * charge_times.y,
		ground_bounds.position.x, ground_bounds.end.x)
	_hit_targets.clear()
	velocity = Vector2.ZERO
	_update_attack_visual()
	queue_redraw()


func _tick_attack(delta: float) -> void:
	var timing := sweep_times if attack == Attack.SWEEP else charge_times
	var previous_time := attack_time
	attack_time += delta
	state = State.WINDUP if attack_time < timing.x else State.ACTIVE
	if attack_time >= timing.x + timing.y:
		state = State.RECOVERY
	# Integrate only the active part of this tick, keeping the charge on its line.
	if attack == Attack.CHARGE:
		var travel_time := maxf(0.0, minf(attack_time, timing.x + timing.y) - maxf(previous_time, timing.x))
		position.x = move_toward(position.x, _charge_end, charge_speed * travel_time)
		if state == State.ACTIVE and is_equal_approx(position.x, _charge_end):
			attack_time = timing.x + timing.y
			state = State.RECOVERY
	if state == State.ACTIVE:
		strike_targets(_attack_facing,
			sweep_reach if attack == Attack.SWEEP else charge_reach, depth_tolerance, 8.0,
			sweep_damage if attack == Attack.SWEEP else charge_damage,
			attack == Attack.CHARGE, _hit_targets)
	_update_attack_visual()
	if attack_time >= timing.x + timing.y + timing.z:
		cancel_attack()


func _update_attack_visual() -> void:
	visual.scale.x = absf(visual.scale.x) * _attack_facing
	sprite.animation = &"sweep" if attack == Attack.SWEEP else &"prepare"
	sprite.pause()
	if attack == Attack.SWEEP:
		sprite.frame = mini(2, int(attack_time / sweep_times.x * 3.0)) \
			if state == State.WINDUP else (3 if state == State.ACTIVE else 5)
	elif state == State.ACTIVE:
		sprite.play(&"move")
	else:
		sprite.frame = 0 if state == State.WINDUP else 1
	$Tell.text = "OPEN" if state == State.RECOVERY else ("SWEEP" if attack == Attack.SWEEP else "CHARGE →" if _attack_facing > 0 else "← CHARGE")
	$Tell.modulate = Color(0.5, 1, 0.7) if state == State.RECOVERY else Color(1, 0.8, 0.25)


func receive_hit(amount: int, direction: Vector2, _knockdown: bool = false) -> bool:
	if amount <= 0 or health == 0:
		return false
	# Lethal damage uses the shared cancellation/single-death receiver path.
	if amount >= health or attack_time < 0.0:
		return super.receive_hit(amount, direction, false)
	health = maxi(0, health - amount)
	_hit_flash = 0.12
	health_changed.emit(health)
	return true


func cancel_attack() -> void:
	attack_time = -1.0
	state = State.APPROACH
	cooldown = 0.35
	_hit_targets.clear()
	velocity = Vector2.ZERO
	$Tell.text = ""
	queue_redraw()


func _draw() -> void:
	if state != State.WINDUP or attack_time < 0.0:
		return
	var reach := sweep_reach if attack == Attack.SWEEP else absf(_charge_end - position.x) + charge_reach
	var end := clampf(position.x + _attack_facing * reach, ground_bounds.position.x, ground_bounds.end.x) - position.x
	draw_rect(Rect2(minf(0.0, end), -depth_tolerance, absf(end), depth_tolerance * 2.0), Color(1, 0.7, 0.15, 0.25))
