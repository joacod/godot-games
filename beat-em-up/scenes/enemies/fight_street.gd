extends "res://scenes/level/movement_street.gd"
## One test fight owns its actors, attack slots, outcome and retry.

@onready var enemies: Array[CharacterBody2D] = [$Actors/GruntLeft, $Actors/GruntRight, $Actors/Bruiser]
@onready var readout: Label = $Overlay/Health
@onready var outcome: Label = $Overlay/Outcome

var slots: Array[CharacterBody2D] = []
var finished: bool = false


func _ready() -> void:
	for enemy in enemies:
		enemy.encounter = self
		enemy.target = player
		enemy.died.connect(_check_result)
	player.died.connect(_check_result)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	readout.text = "Hero %d/%d   Grunts %d / %d   Bruiser %d   Attacking %d/2" % [
		player.health, player.max_health, enemies[0].health, enemies[1].health,
		enemies[2].health, slots.size()]


func claim_slot(enemy: CharacterBody2D) -> bool:
	if finished or get_tree().paused or enemy.health == 0 or not is_visible_fighter(enemy):
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
	var side := -1.0 if index == 0 else 1.0
	if player.position.x + side * 38.0 < enemy.ground_bounds.position.x \
			or player.position.x + side * 38.0 > enemy.ground_bounds.end.x:
		side = -side
	var depth := 0.0 if index == 0 else (-12.0 if index == 1 else 12.0)
	# Distinct waiting lanes keep a third enemy from parking on the active pair.
	if slots.size() >= 2:
		depth = -24.0 if index % 2 == 0 else 24.0
	var destination := player.position + Vector2(side * 38.0, depth)
	return destination.clamp(enemy.ground_bounds.position, enemy.ground_bounds.end)


func _check_result() -> void:
	if finished:
		return
	var living := 0
	for enemy in enemies:
		if enemy.health > 0:
			living += 1
	if player.health > 0 and living > 0:
		return
	finished = true
	for enemy in enemies:
		enemy.cancel_attack()
	player.cancel_attack()
	outcome.text = ("DEFEATED" if player.health == 0 else "FIGHT CLEARED") + "\nR / Back: retry"
	outcome.show()


func reset_test() -> void:
	for enemy in enemies:
		enemy.reset()
	slots.clear()
	finished = false
	outcome.hide()
	super.reset_test()
