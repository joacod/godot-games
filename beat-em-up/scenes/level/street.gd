extends Node2D
## Street progression is independent of the title/pause run owner.

signal hero_died
signal won

const ROUTE_BOUNDS := Rect2(48, 242, 2672, 70)
const BOSS_BOUNDS := Rect2(2180, 242, 540, 70)
const BOSS = preload("res://scenes/enemies/boss.tscn")

@export var debug_bounds: bool = false

@onready var player: CharacterBody2D = $Actors/Player
@onready var camera: Camera2D = $Camera
@onready var encounters: Array[Node] = [$FirstFight, $YardFight]
var active: Node2D
var prompt: String = "Move →   J / west: combo   Space / south: jump"
var reached_entrance: bool = false
var boss: CharacterBody2D
var completed: bool = false


func _ready() -> void:
	$Boundaries.draw.connect(_draw_boundaries)
	player.ground_bounds = ROUTE_BOUNDS
	player.died.connect(_hero_died)
	$Actors/RecoveryProp.player = player
	for encounter in encounters:
		encounter.player = player
		encounter.camera = camera
		encounter.actors = $Actors
		encounter.cleared.connect(_cleared.bind(encounter))
	_update_progress()


func _physics_process(_delta: float) -> void:
	if player.health > 0:
		_update_progress()


func _update_progress() -> void:
	if reached_entrance:
		player.ground_bounds = BOSS_BOUNDS
		camera.position.x = BOSS_BOUNDS.get_center().x
		return
	if active == null:
		for encounter in encounters:
			if not encounter.started and player.position.x >= encounter.arena_bounds.position.x + 60.0:
				active = encounter
				player.ground_bounds = encounter.arena_bounds
				player.position = player.position.clamp(player.ground_bounds.position, player.ground_bounds.end)
				camera.position.x = encounter.arena_bounds.get_center().x
				encounter.start()
				prompt = "Clear the fight — gates locked"
				break
	if active == null:
		player.ground_bounds = ROUTE_BOUNDS
		# A pending arena cannot be crossed between trigger checks, even airborne.
		for encounter in encounters:
			if not encounter.started:
				player.ground_bounds.size.x = encounter.arena_bounds.end.x - ROUTE_BOUNDS.position.x
				break
		camera.position.x = clampf(player.position.x, 320.0, 2880.0)
		if encounters[1].finished and player.position.x >= BOSS_BOUNDS.position.x + 60.0:
			reached_entrance = true
			player.ground_bounds = BOSS_BOUNDS
			player.position = player.position.clamp(BOSS_BOUNDS.position, BOSS_BOUNDS.end)
			camera.position.x = BOSS_BOUNDS.get_center().x
			boss = BOSS.instantiate()
			boss.position = Vector2(2660, 278)
			boss.ground_bounds = BOSS_BOUNDS
			boss.target = player
			$Actors.add_child(boss)
			boss.defeat_finished.connect(_boss_defeated)
			prompt = "Change depth to evade — punish OPEN recovery"
	$Boundaries.queue_redraw()


func _cleared(encounter: Node2D) -> void:
	if player.health == 0 or active != encounter:
		return
	active = null
	prompt = "GO →"
	_update_progress()


func _hero_died() -> void:
	for encounter in encounters:
		for enemy in encounter.enemies:
			enemy.cancel_attack()
	if is_instance_valid(boss):
		boss.cancel_attack()
	hero_died.emit()


func _boss_defeated() -> void:
	if completed or player.health == 0:
		return
	completed = true
	player.cancel_attack()
	prompt = "STREET CLEARED"
	won.emit()


func _draw_boundaries() -> void:
	if debug_bounds:
		$Boundaries.draw_rect(ROUTE_BOUNDS, Color(0.5, 0.95, 0.85, 0.35), false, 1.0)
	for encounter in encounters:
		if encounter == active:
			for x in [encounter.arena_bounds.position.x, encounter.arena_bounds.end.x]:
				_draw_gate(x)
	if reached_entrance:
		for x in [BOSS_BOUNDS.position.x, BOSS_BOUNDS.end.x]:
			_draw_gate(x)


func _draw_gate(x: float) -> void:
	# A ground stripe is an encounter boundary cue, never an actor hitbox.
	$Boundaries.draw_rect(Rect2(x - 5, 242, 10, 70), Color(0.08, 0.1, 0.12, 0.85))
	for y in range(246, 309, 10):
		$Boundaries.draw_line(Vector2(x - 4, y + 5), Vector2(x + 4, y), Color(1, 0.8, 0.4), 2.0)
	$Boundaries.draw_string(ThemeDB.fallback_font, Vector2(x - 22, 232), "LOCK", HORIZONTAL_ALIGNMENT_LEFT,
		-1, 11, Color(1, 0.8, 0.4))
