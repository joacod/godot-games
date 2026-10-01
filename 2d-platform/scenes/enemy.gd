extends CharacterBody2D

## Health restored by a full-level retry.
@export var max_health = 2
## Horizontal patrol speed in pixels per second.
@export var patrol_speed = 90.0
## Patrol endpoints in pixels relative to this instance's starting position.
@export var patrol_left = -90.0
@export var patrol_right = 90.0
@export var attack_damage = 1
@export var windup_duration = 0.55
@export var strike_duration = 0.15
@export var recovery_duration = 0.75

enum CombatState {PATROL, WINDUP, STRIKE, RECOVERY}
var combat_state = CombatState.PATROL
var state_remaining = 0.0
var health = 0
var is_defeated = false
var direction = 1
var start_x = 0.0
var hurt_remaining = 0.0
var knockback_remaining = 0.0
var knockback_speed = 0.0
var hit_players = {}
var impact_direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var awareness = $ContactDamage
@onready var attack_hitbox = $AttackHitbox
@onready var floor_ahead = $FloorAhead

func _ready():
	health = max_health
	start_x = global_position.x
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if is_defeated:
		return
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	knockback_remaining = maxf(0.0, knockback_remaining - delta)
	sprite.modulate = Color(1.7, 1.3, 0.8) if hurt_remaining > 0.0 else Color.WHITE
	if not is_on_floor():
		velocity.y += gravity * delta
	if combat_state == CombatState.PATROL:
		for body in awareness.get_overlapping_bodies():
			if body.has_method("take_damage") and not body.is_dead:
				direction = 1 if body.global_position.x + 44 * body.scale.x >= global_position.x else -1
				combat_state = CombatState.WINDUP
				state_remaining = windup_duration
				sprite.pause()
				hit_players.clear()
				break
	else:
		state_remaining = maxf(0.0, state_remaining - delta)
		if state_remaining == 0.0:
			match combat_state:
				CombatState.WINDUP:
					combat_state = CombatState.STRIKE
					state_remaining = strike_duration
				CombatState.STRIKE:
					combat_state = CombatState.RECOVERY
					state_remaining = recovery_duration
				CombatState.RECOVERY:
					combat_state = CombatState.PATROL
	var left = start_x + patrol_left
	var right = start_x + patrol_right
	velocity.x = 0.0
	if combat_state == CombatState.PATROL:
		if global_position.x >= right:
			direction = -1
		elif global_position.x <= left:
			direction = 1
		if not _safe_step(direction, patrol_speed, delta):
			direction *= -1
		velocity.x = direction * patrol_speed
		if hurt_remaining == 0.0:
			sprite.play("walk")
	if knockback_remaining > 0.0 and _safe_step(signf(knockback_speed), absf(knockback_speed), delta):
		velocity.x = knockback_speed
	velocity.x = clampf(velocity.x, (left - global_position.x) / delta, (right - global_position.x) / delta)
	sprite.flip_h = direction < 0
	attack_hitbox.position.x = direction * 78.0
	move_and_slide()
	if combat_state == CombatState.STRIKE:
		for body in attack_hitbox.get_overlapping_bodies():
			if get_tree().paused:
				break
			if body.has_method("take_damage") and not hit_players.has(body.get_instance_id()):
				hit_players[body.get_instance_id()] = true
				body.take_damage(attack_damage)
	queue_redraw()

func _safe_step(facing, speed, delta):
	# Look beyond the body and this tick's movement before crossing a ledge.
	floor_ahead.position.x = facing * (32.0 + speed * delta)
	floor_ahead.force_raycast_update()
	return not is_on_floor() or (not is_on_wall() and floor_ahead.is_colliding())

func apply_knockback(speed):
	if get_tree().paused:
		return
	impact_direction = -signf(speed)
	queue_redraw()
	if is_defeated:
		return
	knockback_speed = speed
	knockback_remaining = 0.16

func take_damage(amount: int = 1):
	if is_defeated or get_tree().paused or amount <= 0:
		return
	health = maxi(0, health - amount)
	hurt_remaining = 0.14
	if health > 0:
		# A confirmed hit interrupts the attack; recovery cannot deal contact damage.
		combat_state = CombatState.RECOVERY
		state_remaining = recovery_duration
		hit_players.clear()
		sprite.modulate = Color(1.7, 1.3, 0.8)
		sprite.play("hurt")
	else:
		is_defeated = true
		velocity = Vector2.ZERO
		state_remaining = 0.0
		knockback_remaining = 0.0
		hit_players.clear()
		collision_layer = 0
		collision_mask = 0
		awareness.set_deferred("monitoring", false)
		attack_hitbox.set_deferred("monitoring", false)
		sprite.modulate = Color(1.7, 1.3, 0.8)
		sprite.play("dead")
	queue_redraw()

func _draw():
	# Native effects share the fortress gold/teal palette and follow actual timing.
	if hurt_remaining > 0.0:
		var center = Vector2(impact_direction * 24, -90)
		for ray in range(8):
			var axis = Vector2.from_angle(ray * TAU / 8)
			draw_line(center + axis * 10, center + axis * 24, Color(1, 0.9, 0.6), 3)
	if is_defeated:
		return
	if combat_state == CombatState.WINDUP:
		draw_line(Vector2(-4, -194), Vector2(-4, -174), Color(1, 0.8, 0.35), 5)
		draw_circle(Vector2(-4, -165), 3, Color(1, 0.8, 0.35))
		draw_line(Vector2(direction * 35, -5), Vector2(direction * 130, -5), Color(1, 0.8, 0.35, 0.7), 3)
	elif combat_state == CombatState.STRIKE:
		# The visible swipe marks the forward strike rectangle.
		for i in range(3):
			draw_line(Vector2(direction * 23, -115 + i * 35), Vector2(direction * 133, -110 + i * 35), Color(0.75, 1, 0.92), 5)
	elif combat_state == CombatState.RECOVERY:
		draw_circle(Vector2(0, -178), 4, Color(0.45, 0.8, 0.78))

func _on_animation_finished():
	if is_defeated:
		queue_free()
