extends CharacterBody2D

signal died

## Health restored at the start of every run.
@export var max_health = 3
## Seconds during which ordinary damage is ignored after a hit.
@export var invulnerability_duration = 1.0
var health = 0
var invulnerability_remaining = 0.0
var is_dead = false


## Horizontal walking speed in pixels per second.
@export var walk_speed = 400.0
## Horizontal running speed in pixels per second.
@export var run_speed = 700.0
## Upward jump velocity in pixels per second; negative points upward.
@export var jump_velocity = -900.0
## Horizontal slowdown in pixels per second squared (50 per tick at 60 Hz).
@export var deceleration = 3000.0
@onready var player = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 1  # 1 for right, -1 for left
var is_attacking = false
var attack_direction = 1
## Damage dealt to each enemy once per swing.
@export var attack_damage = 1
# Zero-based inclusive striking frames at the existing 10 fps.
const STRIKING_FRAMES = {
	&"attacking1": Vector2i(4, 4),
	&"attacking2": Vector2i(2, 2),
	&"attacking3": Vector2i(2, 3),
}
var attack_active = false
var hit_enemies = {}
@onready var attack_hitbox = $AttackHitbox

# Animation states
enum Animations {DEFAULT, WALKING, RUNNING, JUMPING, ATTACKING1, ATTACKING2, ATTACKING3}
var current_animation = Animations.DEFAULT

# Constants for input actions
# Defined in Project Settings -> Input Map
const INPUT_MOVE_LEFT = "left"
const INPUT_MOVE_RIGHT = "right"
const INPUT_JUMP = "jump"
const INPUT_RUN = "run"
const INPUT_ATTACK1 = "attack1"
const INPUT_ATTACK2 = "attack2"
const INPUT_ATTACK3 = "attack3"

func _ready():
	health = max_health
	player.animation_finished.connect(_on_animation_finished)
	player.frame_changed.connect(_update_attack_hitbox)
	attack_hitbox.body_entered.connect(_hit_enemy)

# This function runs on every physics frame
# at a constant rate (usually 60 times per second)
func _physics_process(delta):
	if is_dead:
		return
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	if invulnerability_remaining > 0.0:
		var blink_alpha = 0.45 if fmod(invulnerability_remaining, 0.2) < 0.1 else 1.0
		player.modulate = Color(1.0, 0.45, 0.45, blink_alpha)
	else:
		player.modulate = Color.WHITE
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_attacks()
	update_animation()
	move_and_slide()
	_update_attack_hitbox()
	# Monitoring stays on so enemies already inside are detected when striking begins.
	if attack_active:
		for enemy in attack_hitbox.get_overlapping_bodies():
			_hit_enemy(enemy)

func _update_attack_hitbox():
	attack_hitbox.position.x = player.position.x + attack_direction * 94.0
	var frames = STRIKING_FRAMES.get(player.animation, Vector2i(-1, -1))
	attack_active = is_attacking and not is_dead and player.frame >= frames.x and player.frame <= frames.y

func _hit_enemy(enemy):
	if not attack_active or is_dead or get_tree().paused or not enemy.has_method("take_damage"):
		return
	var id = enemy.get_instance_id()
	if hit_enemies.has(id):
		return
	hit_enemies[id] = true
	enemy.take_damage(attack_damage)

func take_damage(amount: int = 1):
	if is_dead or invulnerability_remaining > 0.0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	if health == 0:
		kill()
	else:
		invulnerability_remaining = invulnerability_duration
		player.modulate = Color(1.0, 0.45, 0.45, 0.45)

func kill():
	# Lethal hazards bypass invulnerability; emit exactly once.
	if is_dead:
		return
	is_dead = true
	health = 0
	velocity = Vector2.ZERO
	is_attacking = false
	attack_active = false
	hit_enemies.clear()
	invulnerability_remaining = 0.0
	player.modulate = Color.WHITE
	player.stop()
	set_physics_process(false)
	died.emit()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed(INPUT_JUMP) and is_on_floor():
		velocity.y = jump_velocity

# Get the input direction and handle the movement/deceleration.
func handle_movement(delta):
	var direction = Input.get_axis(INPUT_MOVE_LEFT, INPUT_MOVE_RIGHT)
	var speed = walk_speed
	if Input.is_action_pressed(INPUT_RUN):
		speed = run_speed
	if direction != 0:
		velocity.x = direction * speed
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func handle_attacks():
	if is_attacking:
		return

	if Input.is_action_just_pressed(INPUT_ATTACK1):
		current_animation = Animations.ATTACKING1
	elif Input.is_action_just_pressed(INPUT_ATTACK2):
		current_animation = Animations.ATTACKING2
	elif Input.is_action_just_pressed(INPUT_ATTACK3):
		current_animation = Animations.ATTACKING3
	else:
		handle_movement_animations()
		return
	is_attacking = true
	attack_direction = last_direction
	hit_enemies.clear()

func _on_animation_finished():
	if is_dead:
		return
	if is_attacking:
		is_attacking = false
		attack_active = false
		handle_movement_animations()
		update_animation()

func handle_movement_animations():
	if not is_on_floor():
		current_animation = Animations.JUMPING
	elif abs(velocity.x) > 1: # it is moving
		if Input.is_action_pressed(INPUT_RUN):
			current_animation = Animations.RUNNING
		else:
			current_animation = Animations.WALKING
	else:
		current_animation = Animations.DEFAULT

# assigns the current animation to the player
func update_animation():
	match current_animation:
		Animations.JUMPING:
			player.play("jumping")
		Animations.RUNNING:
			player.play("running")
		Animations.WALKING:
			player.play("walking")
		Animations.ATTACKING1:
			player.play("attacking1")
		Animations.ATTACKING2:
			player.play("attacking2")
		Animations.ATTACKING3:
			player.play("attacking3")
		_:
			player.play("default")
	# Change player sprite left or right
	player.flip_h = (attack_direction if is_attacking else last_direction) < 0


# Before refactoring
# Movement of player, jump, run, and animations
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	#var direction = Input.get_axis("left", "right")
	#var speed = WALK_SPEED # Default to WALK_SPEED
	#if Input.is_action_pressed("run"):
		#speed = RUN_SPEED # Change to RUN_SPEED if "run" key is pressed
		#
	#if direction:
		#velocity.x = direction * speed
		#last_direction = direction
	#else:
		#velocity.x = move_toward(velocity.x, 0, 50)
#
	#move_and_slide()
	#
	## Animations
	#if not is_on_floor():
		#player.animation = "jumping"
	#elif abs(velocity.x) > 1:
		#if speed == RUN_SPEED:
			#player.animation = "running"
		#else:
			#player.animation = "walking"
	#else:
		#player.animation = "default"
	#
	## Change sprite left or right
	#player.flip_h = last_direction < 0
