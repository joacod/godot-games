extends CharacterBody2D
## Shared damage receiver and reactions; actors own their decisions and attacks.

signal health_changed(value: int)
signal died
signal damaged
signal attack_started

enum Reaction { READY, HURT, DOWN, GET_UP, DEAD }

@export var max_health: int = 100
@export var team: int = 0
@export var ground_bounds: Rect2 = Rect2(48, 242, 1184, 70)
@export var hurt_duration: float = 0.24
@export var invulnerability_duration: float = 0.65
@export var down_duration: float = 0.75
@export var get_up_duration: float = 0.3
@export var knockback_speed: float = 100.0
@export var jump_gravity: float = 780.0

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite

var health: int
var reaction: Reaction = Reaction.READY
var reaction_time: float = 0.0
var invulnerability: float = 0.0
var jump_height: float = 0.0
var _jump_velocity: float = 0.0
var _facing: float = 1.0
var _knockback: Vector2 = Vector2.ZERO
var _spawn_position: Vector2


func _ready() -> void:
	_spawn_position = position
	health = max_health
	add_to_group("damage_receivers")


func receive_hit(amount: int, direction: Vector2, knockdown: bool = false) -> bool:
	if amount <= 0 or reaction == Reaction.DEAD or invulnerability > 0.0 \
			or reaction == Reaction.DOWN or reaction == Reaction.GET_UP:
		return false
	health = maxi(0, health - amount)
	cancel_attack()
	velocity = Vector2.ZERO
	_knockback = direction.normalized() * knockback_speed
	reaction_time = 0.0
	invulnerability = invulnerability_duration
	if health == 0:
		reaction = Reaction.DEAD
	elif knockdown or jump_height > 0.0:
		reaction = Reaction.DOWN
	else:
		reaction = Reaction.HURT
	health_changed.emit(health)
	damaged.emit()
	if health == 0:
		died.emit()
	return true


func cancel_attack() -> void:
	pass


func tick_reaction(delta: float) -> void:
	invulnerability = maxf(0.0, invulnerability - delta)
	if reaction == Reaction.READY:
		return
	reaction_time += delta
	velocity = _knockback if reaction_time < hurt_duration else Vector2.ZERO
	move_and_slide()
	position = position.clamp(ground_bounds.position, ground_bounds.end)
	if jump_height > 0.0:
		_jump_velocity -= jump_gravity * delta
		jump_height = maxf(0.0, jump_height + _jump_velocity * delta)
		if jump_height == 0.0:
			_jump_velocity = 0.0
	if jump_height == 0.0:
		if reaction == Reaction.HURT and reaction_time >= hurt_duration:
			reaction = Reaction.READY
		elif reaction == Reaction.DOWN and reaction_time >= down_duration:
			reaction = Reaction.GET_UP
			reaction_time = 0.0
		elif reaction == Reaction.GET_UP and reaction_time >= get_up_duration:
			reaction = Reaction.READY
			invulnerability = maxf(invulnerability, 0.2)


func update_reaction_visual() -> void:
	visual.position.y = -jump_height
	visual.scale.x = absf(visual.scale.x) * _facing
	sprite.modulate = Color(1, 0.65, 0.65) if invulnerability > 0.0 \
			and int(invulnerability * 20.0) % 2 == 0 else Color.WHITE
	if reaction == Reaction.READY:
		return
	var animation: StringName = &"hurt" if reaction == Reaction.HURT else &"fall"
	if reaction == Reaction.GET_UP:
		animation = &"get_up"
	sprite.animation = animation
	sprite.pause()
	var duration := hurt_duration if reaction == Reaction.HURT else get_up_duration
	if reaction == Reaction.DOWN or reaction == Reaction.DEAD:
		duration = 0.3
	sprite.frame = mini(sprite.sprite_frames.get_frame_count(animation) - 1,
		int(reaction_time / duration * sprite.sprite_frames.get_frame_count(animation)))


func reset() -> void:
	cancel_attack()
	position = _spawn_position
	health = max_health
	reaction = Reaction.READY
	reaction_time = 0.0
	invulnerability = 0.0
	jump_height = 0.0
	_jump_velocity = 0.0
	_knockback = Vector2.ZERO
	velocity = Vector2.ZERO
	_facing = 1.0
	sprite.modulate = Color.WHITE
	health_changed.emit(health)


func strike_targets(facing: float, reach: float, depth: float, height: float,
		amount: int, knockdown: bool, hit_targets: Dictionary) -> void:
	for target in get_tree().get_nodes_in_group("damage_receivers"):
		if target == self or target.team == team or hit_targets.has(target.get_instance_id()):
			continue
		var offset: Vector2 = target.global_position - global_position
		if offset.x * facing < 0.0 or offset.x * facing > reach \
				or absf(offset.y) > depth or jump_height > height or target.jump_height > height:
			continue
		# Register even a protected target so a single strike never hits it later.
		hit_targets[target.get_instance_id()] = true
		target.receive_hit(amount, Vector2(facing, 0), knockdown)
