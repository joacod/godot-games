extends "res://scripts/combat_actor.gd"
## Ordinary melee decisions; the fight owner arbitrates attack commitments.

enum State { APPROACH, WINDUP, ACTIVE, RECOVERY }

@export var move_speed: float = 85.0
@export var strike_times: Vector3 = Vector3(0.4, 0.1, 0.4)
@export var strike_damage: int = 12
@export var strike_reach: float = 60.0
@export var depth_tolerance: float = 14.0
@export var knocks_down: bool = false

var encounter: Node2D
var target: CharacterBody2D
var state: State = State.APPROACH
var attack_time: float = -1.0
var cooldown: float = 0.4
var _hit_targets: Dictionary = {}
var _attack_facing: float = 1.0


func _physics_process(delta: float) -> void:
	tick_reaction(delta)
	update_reaction_visual()
	if reaction != Reaction.READY:
		return
	cooldown = maxf(0.0, cooldown - delta)
	if encounter == null or encounter.finished or target.health == 0:
		cancel_attack()
		sprite.play(&"idle")
		return
	if attack_time >= 0.0:
		_tick_attack(delta)
		return
	var offset: Vector2 = target.position - position
	if absf(offset.x) > 2.0:
		_facing = signf(offset.x)
	if cooldown == 0.0 and absf(offset.x) >= 16.0 and absf(offset.x) <= strike_reach \
			and absf(offset.y) <= depth_tolerance and target.jump_height <= 8.0 \
			and encounter.is_visible_fighter(self) and encounter.claim_slot(self):
		attack_time = 0.0
		_attack_facing = _facing
		state = State.WINDUP
		velocity = Vector2.ZERO
		attack_started.emit()
		_tick_attack(delta)
		return
	var destination: Vector2 = encounter.approach_position(self)
	var travel := destination - position
	var steering := travel
	# Repulsion acts only on mobile living actors; committed attacks never slide.
	for other in encounter.enemies:
		if other == self or other.health == 0:
			continue
		var apart: Vector2 = position - other.position
		if apart.length() < 24.0:
			if apart.length() < 0.1:
				apart = Vector2(0, -1 if get_index() < other.get_index() else 1)
			steering += apart.normalized() * (24.0 - apart.length())
	velocity = steering.normalized() * minf(move_speed, steering.length() * 6.0) \
		if steering.length() > 2.0 else Vector2.ZERO
	move_and_slide()
	position = position.clamp(ground_bounds.position, ground_bounds.end)
	visual.scale.x = absf(visual.scale.x) * _facing
	sprite.play(&"move" if velocity.length() > 2.0 else &"idle")


func _tick_attack(delta: float) -> void:
	attack_time += delta
	state = State.WINDUP if attack_time < strike_times.x else State.ACTIVE
	if attack_time >= strike_times.x + strike_times.y:
		state = State.RECOVERY
	if state == State.ACTIVE:
		strike_targets(_attack_facing, strike_reach, depth_tolerance, 8.0,
			strike_damage, knocks_down, _hit_targets)
	sprite.animation = &"attack"
	sprite.pause()
	visual.scale.x = absf(visual.scale.x) * _attack_facing
	# Source index 4 is contact in both melee sheets; preceding poses are the tell.
	if state == State.WINDUP:
		sprite.frame = mini(3, int(attack_time / strike_times.x * 4))
	else:
		sprite.frame = 4 if state == State.ACTIVE else 5
	if attack_time >= strike_times.x + strike_times.y + strike_times.z:
		cancel_attack()


func cancel_attack() -> void:
	if encounter != null:
		encounter.release_slot(self)
	attack_time = -1.0
	state = State.APPROACH
	cooldown = 0.4
	_hit_targets.clear()
	velocity = Vector2.ZERO


func reset() -> void:
	super.reset()
	update_reaction_visual()
	sprite.play(&"idle")
