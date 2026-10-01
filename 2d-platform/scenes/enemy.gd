extends CharacterBody2D

## Health restored by a full-level retry; each player attack deals one by default.
@export var max_health = 2
## Horizontal patrol speed in pixels per second.
@export var patrol_speed = 90.0
## Patrol endpoints in pixels relative to this instance's starting position.
@export var patrol_left = -90.0
@export var patrol_right = 90.0
@export var contact_damage = 1

var health = 0
var is_defeated = false
var direction = 1
var start_x = 0.0
var hurt_remaining = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var contact = $ContactDamage
@onready var floor_ahead = $FloorAhead

func _ready():
	health = max_health
	start_x = global_position.x
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if is_defeated:
		return
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	sprite.modulate = Color(1.0, 0.5, 0.5) if hurt_remaining > 0.0 else Color.WHITE
	if not is_on_floor():
		velocity.y += gravity * delta
	var left = start_x + patrol_left
	var right = start_x + patrol_right
	if global_position.x >= right:
		direction = -1
	elif global_position.x <= left:
		direction = 1
	# Look beyond the body and this tick's movement before crossing a ledge.
	floor_ahead.position.x = direction * (32.0 + patrol_speed * delta)
	floor_ahead.force_raycast_update()
	if is_on_floor() and (is_on_wall() or not floor_ahead.is_colliding()):
		direction *= -1
	velocity.x = direction * patrol_speed
	velocity.x = clampf(velocity.x, (left - global_position.x) / delta, (right - global_position.x) / delta)
	sprite.flip_h = direction < 0
	if hurt_remaining == 0.0:
		sprite.play("walk")
	move_and_slide()
	# Staying in contact can hit again only after the player's invulnerability expires.
	for body in contact.get_overlapping_bodies():
		if is_defeated or get_tree().paused:
			break
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)

func take_damage(amount: int = 1):
	if is_defeated or amount <= 0:
		return
	health = maxi(0, health - amount)
	if health > 0:
		hurt_remaining = 0.3
		sprite.modulate = Color(1.0, 0.5, 0.5)
		sprite.play("hurt")
	else:
		is_defeated = true
		velocity = Vector2.ZERO
		hurt_remaining = 0.0
		collision_layer = 0
		collision_mask = 0
		contact.set_deferred("monitoring", false)
		sprite.modulate = Color.WHITE
		sprite.play("dead")

func _on_animation_finished():
	if is_defeated:
		queue_free()
