extends CharacterBody2D

signal health_changed(value: int)
signal defeated

@export var max_health: int = 12
@export var attack_damage: int = 1
@export var idle_duration: float = 0.7
@export var sweep_telegraph: float = 0.7
@export var sweep_duration: float = 0.22
@export var wave_telegraph: float = 1.0
@export var wave_duration: float = 2.2
@export var wave_speed: float = 650.0
@export var recovery_duration: float = 1.2
@export var phase_two_recovery: float = 0.85

enum CombatState {IDLE, TELEGRAPH, ATTACK, RECOVERY, DEFEATED}
enum Attack {SWEEP, SHOCKWAVE}
var combat_state: CombatState = CombatState.IDLE
var attack: Attack = Attack.SWEEP
var state_remaining: float = 0.0
var health: int = 0
var active: bool = false
var is_defeated: bool = false
var facing: int = -1
var hurt_remaining: float = 0.0
var hit_players: Dictionary[int, bool] = {}
var wave_hits: Dictionary[int, bool] = {}
var target
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sweep: Area2D = $Sweep
@onready var waves: Array[Area2D] = [$LeftWave, $RightWave]

func _ready() -> void:
	health = max_health
	for wave in waves:
		wave.hide()

func start_encounter(character) -> void:
	if active or is_defeated:
		return
	target = character
	active = true
	state_remaining = idle_duration
	health_changed.emit(health)

func _physics_process(delta: float) -> void:
	if not active or is_defeated:
		return
	hurt_remaining = maxf(0.0, hurt_remaining - delta)
	sprite.modulate = Color(1.8, 1.5, 1.0) if hurt_remaining > 0 else Color(0.75, 0.9, 0.85)
	state_remaining = maxf(0.0, state_remaining - delta)
	if state_remaining == 0:
		match combat_state:
			CombatState.IDLE:
				_begin_telegraph()
			CombatState.TELEGRAPH:
				combat_state = CombatState.ATTACK
				state_remaining = sweep_duration if attack == Attack.SWEEP else wave_duration
				if attack == Attack.SHOCKWAVE:
					for index in range(2):
						waves[index].position.x = -70 if index == 0 else 70
						waves[index].show()
			CombatState.ATTACK:
				_clear_attacks()
				combat_state = CombatState.RECOVERY
				state_remaining = phase_two_recovery if health <= max_health / 2.0 else recovery_duration
			CombatState.RECOVERY:
				attack = Attack.SHOCKWAVE if attack == Attack.SWEEP else Attack.SWEEP
				combat_state = CombatState.IDLE
				state_remaining = idle_duration
	if combat_state == CombatState.ATTACK:
		if attack == Attack.SWEEP:
			_damage_overlaps(sweep, hit_players)
		else:
			for index in range(2):
				var wave = waves[index]
				wave.position.x += (-1 if index == 0 else 1) * wave_speed * delta
				# Waves stop at the closed courtyard boundaries, never enter the route.
				if wave.global_position.x <= 9184 or wave.global_position.x >= 10816:
					wave.hide()
				if wave.visible:
					_damage_overlaps(wave, wave_hits)
	queue_redraw()

func _begin_telegraph() -> void:
	combat_state = CombatState.TELEGRAPH
	state_remaining = sweep_telegraph if attack == Attack.SWEEP else wave_telegraph
	# Commit facing before the tell; the sweep never tracks a dodging player.
	facing = 1 if target.global_position.x + 44 >= global_position.x else -1
	sprite.flip_h = facing < 0
	sweep.position.x = facing * 155
	hit_players.clear()
	wave_hits.clear()

func _damage_overlaps(area: Area2D, hits: Dictionary[int, bool]) -> void:
	for body in area.get_overlapping_bodies():
		if get_tree().paused or not active:
			return
		if body == target and not body.is_dead and not hits.has(body.get_instance_id()):
			hits[body.get_instance_id()] = true
			body.take_damage(attack_damage)

func take_damage(amount: int = 1) -> void:
	if not active or is_defeated or get_tree().paused or amount <= 0:
		return
	health = maxi(0, health - amount)
	hurt_remaining = 0.14
	health_changed.emit(health)
	# All windows are vulnerable. Hits flash without cancelling the committed tell.
	if health == 0:
		is_defeated = true
		combat_state = CombatState.DEFEATED
		stop_encounter()
		collision_layer = 0
		sprite.play("dead")
		defeated.emit()
	queue_redraw()

func stop_encounter() -> void:
	active = false
	state_remaining = 0.0
	hurt_remaining = 0.0
	_clear_attacks()
	if not is_defeated:
		sprite.pause()
	queue_redraw()

func _clear_attacks() -> void:
	hit_players.clear()
	wave_hits.clear()
	for wave in waves:
		wave.hide()
		wave.position.x = 0

func _draw() -> void:
	if is_defeated:
		return
	# A stone-gold crown distinguishes the guardian from the ordinary Gorgon.
	draw_colored_polygon(PackedVector2Array([Vector2(-40, -210), Vector2(-44, -238), Vector2(-20, -226), Vector2(0, -252), Vector2(20, -226), Vector2(44, -238), Vector2(40, -210)]), Color(0.78, 0.68, 0.43))
	if not active:
		return
	if combat_state == CombatState.TELEGRAPH:
		draw_line(Vector2(0, -300), Vector2(0, -279), Color(1, 0.8, 0.35), 5)
		if attack == Attack.SWEEP:
			draw_rect(Rect2(Vector2(facing * 155 - 110, -150), Vector2(220, 120)), Color(1, 0.8, 0.35, 0.28))
		else:
			draw_line(Vector2(-150, -8), Vector2(150, -8), Color(1, 0.8, 0.35), 6)
			for x in [-110, 110]:
				draw_line(Vector2(x, -8), Vector2(x * 1.3, -30), Color(1, 0.8, 0.35), 5)
	elif combat_state == CombatState.ATTACK and attack == Attack.SWEEP:
		for y in [-125, -90, -55]:
			draw_line(Vector2(facing * 45, y), Vector2(facing * 265, y), Color(0.75, 1, 0.92), 7)
	elif combat_state == CombatState.RECOVERY:
		draw_circle(Vector2(0, -290), 7, Color(0.45, 0.8, 0.78))
	if hurt_remaining > 0:
		for ray in range(8):
			var axis = Vector2.from_angle(ray * TAU / 8)
			draw_line(Vector2(0, -135) + axis * 40, Vector2(0, -135) + axis * 60, Color(1, 0.9, 0.6), 4)
