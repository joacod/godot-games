extends CharacterBody2D
## The body stays on the street plane; only Visual rises during a jump.

@export var move_speed: float = 130.0
@export var jump_speed: float = 260.0
@export var jump_gravity: float = 780.0
@export var ground_bounds: Rect2 = Rect2(48, 242, 1184, 70)

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite

var jump_height: float = 0.0
var _jump_velocity: float = 0.0
var _facing: float = 1.0
var _waiting_for_release: bool = true
var _spawn_position: Vector2


func _ready() -> void:
	_spawn_position = position
	_update_visual()


func _physics_process(delta: float) -> void:
	if _waiting_for_release:
		_waiting_for_release = Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO \
				or Input.is_action_pressed("jump") or Input.is_action_pressed("attack") \
				or Input.is_action_pressed("ui_accept") or Input.is_action_pressed("pause") \
				or Input.is_action_pressed("test_reset")

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _waiting_for_release:
		direction = Vector2.ZERO
	velocity = direction * move_speed
	move_and_slide()
	position = position.clamp(ground_bounds.position, ground_bounds.end)
	if not is_zero_approx(direction.x):
		_facing = signf(direction.x)

	if not _waiting_for_release and Input.is_action_just_pressed("jump") \
			and is_zero_approx(jump_height):
		_jump_velocity = jump_speed
	if _jump_velocity > 0.0 or jump_height > 0.0:
		_jump_velocity -= jump_gravity * delta
		jump_height = maxf(0.0, jump_height + _jump_velocity * delta)
		if is_zero_approx(jump_height):
			_jump_velocity = 0.0
	_update_visual()


func require_input_release() -> void:
	_waiting_for_release = true
	velocity = Vector2.ZERO


func reset() -> void:
	position = _spawn_position
	jump_height = 0.0
	_jump_velocity = 0.0
	_facing = 1.0
	require_input_release()
	sprite.stop()
	_update_visual()


func _update_visual() -> void:
	visual.position.y = -jump_height
	visual.scale.x = 2.0 * _facing
	if jump_height > 0.0:
		sprite.animation = &"jump"
		sprite.pause()
		# Choose ascent/apex/descent poses from the existing four-frame sheet.
		sprite.frame = 1 if _jump_velocity > 60.0 else (2 if _jump_velocity >= -60.0 else 3)
	else:
		sprite.play(&"move" if velocity.length_squared() > 0.0 else &"idle")
