extends Node2D
## A single arena owns queued waves, living actors and attack reservations.

signal cleared

@export var arena_bounds: Rect2
@export var waves: Array[PackedScene] = []
@export var wave_sizes: Array[int] = []
@export var wave_delay: float = 1.2

var player: CharacterBody2D
var camera: Camera2D
var actors: Node2D
var enemies: Array[CharacterBody2D] = []
var slots: Array[CharacterBody2D] = []
var started: bool = false
var finished: bool = false
var next_wave: int = 0
var spawn_cursor: int = 0
var pending_time: float = 0.0
var living: Dictionary = {}


func start() -> void:
	if started or player.health == 0:
		return
	started = true
	_spawn_wave()


func _physics_process(delta: float) -> void:
	if not started or finished or player.health == 0 or not living.is_empty():
		return
	pending_time = maxf(0.0, pending_time - delta)
	if pending_time == 0.0:
		_spawn_wave()


func _spawn_wave() -> void:
	if player.health == 0 or get_tree().paused or next_wave >= wave_sizes.size():
		return
	var markers := $Spawns.get_children()
	# Choose the farthest authored markers first; each is visible and reachable.
	markers.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.position.distance_to(player.position) > b.position.distance_to(player.position))
	for index in range(wave_sizes[next_wave]):
		var enemy: CharacterBody2D = waves[spawn_cursor + index].instantiate()
		enemy.position = markers[index].position
		enemy.ground_bounds = arena_bounds
		enemy.encounter = self
		enemy.target = player
		actors.add_child(enemy)
		enemies.append(enemy)
		living[enemy.get_instance_id()] = true
		enemy.died.connect(_enemy_died.bind(enemy))
	spawn_cursor += wave_sizes[next_wave]
	next_wave += 1


func _enemy_died(enemy: CharacterBody2D) -> void:
	var id := enemy.get_instance_id()
	if not living.has(id):
		return
	living.erase(id)
	release_slot(enemy)
	if not living.is_empty() or player.health == 0:
		return
	if next_wave < wave_sizes.size():
		pending_time = wave_delay
	else:
		finished = true
		cleared.emit()


func claim_slot(enemy: CharacterBody2D) -> bool:
	if finished or player.health == 0 or get_tree().paused or enemy.health == 0 \
			or not is_visible_fighter(enemy):
		return false
	if slots.has(enemy):
		return true
	if slots.size() >= 2:
		return false
	slots.append(enemy)
	return true


func release_slot(enemy: CharacterBody2D) -> void:
	slots.erase(enemy)


func is_visible_fighter(enemy: CharacterBody2D) -> bool:
	return absf(enemy.position.x - camera.position.x) <= 280.0


func approach_position(enemy: CharacterBody2D) -> Vector2:
	var index := enemies.find(enemy)
	var side := -1.0 if index % 2 == 0 else 1.0
	if not arena_bounds.has_point(player.position + Vector2(side * 38.0, 0)):
		side = -side
	var depth := (-12.0 if index % 2 == 0 else 12.0) if slots.size() < 2 \
		else (-24.0 if index % 2 == 0 else 24.0)
	return (player.position + Vector2(side * 38.0, depth)).clamp(arena_bounds.position, arena_bounds.end)
