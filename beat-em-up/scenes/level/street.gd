extends Node2D
## Street progression is independent of the title/pause run owner.

signal hero_died

const ROUTE_BOUNDS := Rect2(48, 242, 2416, 70)

@onready var player: CharacterBody2D = $Actors/Player
@onready var camera: Camera2D = $Camera
@onready var encounters: Array[Node] = [$FirstFight, $YardFight]
var active: Node2D
var prompt: String = "Move →  J: combo   Space: jump"
var reached_entrance: bool = false


func _ready() -> void:
	$Boundaries.draw.connect(_draw_boundaries)
	player.ground_bounds = ROUTE_BOUNDS
	player.died.connect(_hero_died)
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
		camera.position.x = clampf(player.position.x, 320.0, 2240.0)
		if encounters[1].finished and player.position.x >= 2300.0:
			reached_entrance = true
			prompt = "BOSS ENTRANCE SEALED — boss arrives in Step 06"
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
	hero_died.emit()


func _draw_boundaries() -> void:
	$Boundaries.draw_rect(ROUTE_BOUNDS, Color(0.5, 0.95, 0.85, 0.35), false, 1.0)
	for encounter in encounters:
		if encounter == active:
			for x in [encounter.arena_bounds.position.x, encounter.arena_bounds.end.x]:
				$Boundaries.draw_line(Vector2(x, 220), Vector2(x, 318), Color(1, 0.7, 0.2), 5.0)
	$Boundaries.draw_line(Vector2(2464, 210), Vector2(2464, 318), Color(0.8, 0.3, 0.3), 8.0)
