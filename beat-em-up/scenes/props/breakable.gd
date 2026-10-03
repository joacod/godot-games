extends Node2D
## A nonblocking receiver; the broken flag owns the single deterministic drop.

signal broken
signal damaged

const FOOD = preload("res://scenes/props/food.tscn")

@export var max_health: int = 20
@export var food_recovery: int = 30

# Enemy team prevents enemy strikes from breaking the player's recovery prop.
var team: int = 1
var jump_height: float = 0.0
var health: int
var is_broken: bool = false
var player: CharacterBody2D


func _ready() -> void:
	health = max_health
	add_to_group("damage_receivers")


func receive_hit(amount: int, _direction: Vector2, _knockdown: bool = false) -> bool:
	if amount <= 0 or is_broken:
		return false
	health = maxi(0, health - amount)
	if health == 0:
		is_broken = true
		$Intact.hide()
		$Debris.show()
		$Hint.hide()
		var food := FOOD.instantiate()
		food.position = position + Vector2(32, 0)
		food.player = player
		food.recovery = food_recovery
		get_parent().add_child(food)
		broken.emit()
	damaged.emit()
	return true
