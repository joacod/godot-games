extends CharacterBody2D


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
	player.animation_finished.connect(_on_animation_finished)

# This function runs on every physics frame
# at a constant rate (usually 60 times per second)
func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_attacks()
	update_animation()
	move_and_slide()

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

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
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
