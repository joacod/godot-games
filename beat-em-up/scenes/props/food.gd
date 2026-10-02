extends Node2D
## Ground-plane proximity, independent of sprite overlap and jump visuals.

signal collected

@export var recovery: int = 30
@export var pickup_reach: float = 22.0
@export var depth_tolerance: float = 12.0

var player: CharacterBody2D
var is_collected: bool = false


func _ready() -> void:
	add_to_group("food_pickups")
	$Hint.text = "FOOD +%d" % recovery


func _physics_process(_delta: float) -> void:
	try_collect()


func try_collect() -> bool:
	if is_collected or not is_instance_valid(player):
		return false
	var offset := player.global_position - global_position
	if absf(offset.x) > pickup_reach or absf(offset.y) > depth_tolerance:
		return false
	# Guard before health_changed emits, including callbacks in the same tick.
	is_collected = true
	if player.restore_health(recovery) == 0:
		is_collected = false
		return false
	hide()
	collected.emit()
	queue_free()
	return true
