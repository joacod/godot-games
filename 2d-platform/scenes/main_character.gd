extends CharacterBody2D


const WALK_SPEED = 400.0
const RUN_SPEED = 700.0
const JUMP_VELOCITY = -900.0
@onready var player = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = 1  # 1 for right, -1 for left

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

# This function runs on every physics frame
# at a constant rate (usually 60 times per second)
func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	handle_movement()
	handle_attacks()
	update_animation()
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed(INPUT_JUMP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

# Get the input direction and handle the movement/deceleration.
func handle_movement():
	var direction = Input.get_axis(INPUT_MOVE_LEFT, INPUT_MOVE_RIGHT)
	var speed = WALK_SPEED # Default to WALK_SPEED
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED # Change to RUN_SPEED if "run" key is pressed
	if direction != 0:
		velocity.x = direction * speed
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, 50)

func handle_attacks():
	if Input.is_action_just_pressed(INPUT_ATTACK1):
		current_animation = Animations.ATTACKING1
	elif Input.is_action_just_pressed(INPUT_ATTACK2):
		current_animation = Animations.ATTACKING2
	elif Input.is_action_just_pressed(INPUT_ATTACK3):
		current_animation = Animations.ATTACKING3
	else:
		handle_movement_animations()

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
			player.animation = "jumping"
		Animations.RUNNING:
			player.animation = "running"
		Animations.WALKING:
			player.animation = "walking"
		Animations.ATTACKING1:
			player.animation = "attacking1"
		Animations.ATTACKING2:
			player.animation = "attacking2"
		Animations.ATTACKING3:
			player.animation = "attacking3"
		_:
			player.animation = "default"
	# Change player sprite left or right
	player.flip_h = last_direction < 0
