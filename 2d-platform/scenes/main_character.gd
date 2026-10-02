extends CharacterBody2D

signal died
signal health_changed(value: int)

## Health restored at the start of every run.
@export var max_health: int = 3
## Seconds during which ordinary damage is ignored after a hit.
@export var invulnerability_duration: float = 1.0
var health: int = 0
var invulnerability_remaining: float = 0.0
var is_dead: bool = false


## Horizontal walking speed in pixels per second.
@export var walk_speed: float = 400.0
## Horizontal running speed in pixels per second.
@export var run_speed: float = 700.0
## Upward jump velocity in pixels per second; negative points upward.
@export var jump_velocity: float = -900.0
## Seconds after leaving a ledge during which Jump still works.
@export var coyote_time: float = 0.12
## Seconds a fresh Jump press waits for a landing.
@export var jump_buffer_time: float = 0.12
## Remaining upward speed after releasing Jump early (fraction of full speed).
@export_range(0.0, 1.0) var jump_cut_ratio: float = 0.45
var coyote_remaining: float = 0.0
var jump_buffer_remaining: float = 0.0
var jump_in_progress: bool = false
# A menu confirm or held Jump must be released before a new jump request.
var jump_armed: bool = false
## Horizontal slowdown in pixels per second squared (50 per tick at 60 Hz).
@export var deceleration: float = 3000.0
@onready var player: AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction: int = 1  # 1 for right, -1 for left
var is_attacking: bool = false
var attack_direction: int = 1
## Damage dealt once per target by the thrust, quick strike, and heavy uppercut.
@export var thrust_damage: int = 1
@export var quick_damage: int = 1
@export var heavy_damage: int = 2
# Reach follows the visible extended limb; offset is from the sprite origin.
const ATTACK_SHAPES = {
	&"attacking1": Vector3(86, 72, 140),
	&"attacking2": Vector3(64, 64, 100),
	&"attacking3": Vector3(66, 76, 200),
}
# Zero-based inclusive striking frames; animation playback owns timing.
const STRIKING_FRAMES = {
	&"attacking1": Vector2i(4, 4),
	&"attacking2": Vector2i(2, 2),
	&"attacking3": Vector2i(3, 3),
}
var attack_active: bool = false
var hit_enemies: Dictionary[int, bool] = {}
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: RectangleShape2D = $AttackHitbox/CollisionShape2D.shape

# Animation states
enum Animations {DEFAULT, WALKING, RUNNING, JUMPING, ATTACKING1, ATTACKING2, ATTACKING3}
var current_animation: Animations = Animations.DEFAULT

# Constants for input actions
# Defined in Project Settings -> Input Map
const INPUT_MOVE_LEFT = "left"
const INPUT_MOVE_RIGHT = "right"
const INPUT_JUMP = "jump"
const INPUT_RUN = "run"
const INPUT_ATTACK1 = "attack1"
const INPUT_ATTACK2 = "attack2"
const INPUT_ATTACK3 = "attack3"

func _ready() -> void:
	health = max_health
	# Each player owns its shape; tuning a swing must not change another instance.
	attack_shape = attack_shape.duplicate()
	$AttackHitbox/CollisionShape2D.shape = attack_shape
	player.animation_finished.connect(_on_animation_finished)
	player.frame_changed.connect(_update_attack_hitbox)
	attack_hitbox.body_entered.connect(_hit_enemy)

# This function runs on every physics frame
# at a constant rate (usually 60 times per second)
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	if invulnerability_remaining > 0.0:
		var blink_alpha = 0.45 if fmod(invulnerability_remaining, 0.2) < 0.1 else 1.0
		player.modulate = Color(1.0, 0.45, 0.45, blink_alpha)
	else:
		player.modulate = Color.WHITE
	handle_gravity(delta)
	handle_jump(delta)
	handle_movement(delta)
	handle_attacks()
	update_animation()
	move_and_slide()
	if is_on_floor():
		jump_in_progress = false
	_update_attack_hitbox()
	# Monitoring stays on so enemies already inside are detected when striking begins.
	if attack_active:
		for enemy in attack_hitbox.get_overlapping_bodies():
			_hit_enemy(enemy)

func _update_attack_hitbox() -> void:
	var spec: Vector3 = ATTACK_SHAPES.get(player.animation, Vector3(80, 64, 0))
	attack_hitbox.position.x = player.position.x + attack_direction * spec.x
	attack_hitbox.position.y = 24 if player.animation == &"attacking3" else (40 if player.animation == &"attacking1" else 60)
	attack_shape.size = Vector2(spec.y, 112 if player.animation == &"attacking3" else 80)
	var frames: Vector2i = STRIKING_FRAMES.get(player.animation, Vector2i(-1, -1))
	attack_active = is_attacking and not is_dead and player.frame >= frames.x and player.frame <= frames.y

func _hit_enemy(enemy) -> void:
	if not attack_active or is_dead or get_tree().paused or not enemy.has_method("take_damage"):
		return
	var id = enemy.get_instance_id()
	if hit_enemies.has(id):
		return
	hit_enemies[id] = true
	var damage = thrust_damage
	if player.animation == &"attacking2":
		damage = quick_damage
	elif player.animation == &"attacking3":
		damage = heavy_damage
	enemy.take_damage(damage)
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(attack_direction * ATTACK_SHAPES[player.animation].z)

func take_damage(amount: int = 1) -> void:
	if is_dead or get_tree().paused or invulnerability_remaining > 0.0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	if health == 0:
		kill()
	else:
		health_changed.emit(health)
		invulnerability_remaining = invulnerability_duration
		player.modulate = Color(1.0, 0.45, 0.45, 0.45)

func kill() -> void:
	# Lethal hazards bypass invulnerability; emit exactly once.
	if is_dead or get_tree().paused:
		return
	is_dead = true
	health = 0
	health_changed.emit(health)
	clear_movement_state()
	is_attacking = false
	attack_active = false
	hit_enemies.clear()
	invulnerability_remaining = 0.0
	player.modulate = Color.WHITE
	player.stop()
	set_physics_process(false)
	died.emit()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func clear_jump_input() -> void:
	jump_buffer_remaining = 0.0
	jump_armed = false

func clear_movement_state() -> void:
	clear_jump_input()
	coyote_remaining = 0.0
	jump_in_progress = false
	velocity = Vector2.ZERO

func handle_jump(delta: float) -> void:
	if is_on_floor() and not jump_in_progress:
		coyote_remaining = coyote_time
	else:
		coyote_remaining = maxf(0.0, coyote_remaining - delta)
	jump_buffer_remaining = maxf(0.0, jump_buffer_remaining - delta)
	var jump_held = Input.is_action_pressed(INPUT_JUMP)
	var jump_pressed = Input.is_action_just_pressed(INPUT_JUMP) and jump_armed
	if not jump_held:
		jump_armed = true
	elif jump_pressed:
		jump_armed = false
		jump_buffer_remaining = jump_buffer_time
	if (jump_pressed or jump_buffer_remaining > 0.0) and (is_on_floor() or coyote_remaining > 0.0) and not jump_in_progress:
		velocity.y = jump_velocity
		jump_buffer_remaining = 0.0
		coyote_remaining = 0.0
		jump_in_progress = true
	# Also shorten a buffered jump whose button was released before landing.
	if jump_in_progress and not jump_held and velocity.y < jump_velocity * jump_cut_ratio:
		velocity.y = jump_velocity * jump_cut_ratio

# Get the input direction and handle the movement/deceleration.
func handle_movement(delta: float) -> void:
	var direction = Input.get_axis(INPUT_MOVE_LEFT, INPUT_MOVE_RIGHT)
	var speed = walk_speed
	if Input.is_action_pressed(INPUT_RUN):
		speed = run_speed
	if direction != 0:
		velocity.x = direction * speed
		last_direction = int(signf(direction))
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func handle_attacks() -> void:
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

func _on_animation_finished() -> void:
	if is_dead:
		return
	if is_attacking:
		is_attacking = false
		attack_active = false
		handle_movement_animations()
		update_animation()

func handle_movement_animations() -> void:
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
func update_animation() -> void:
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
