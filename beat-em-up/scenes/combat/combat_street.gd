extends "res://scenes/level/movement_street.gd"
## Combat test controls, readout, and reset; no encounters or enemy decisions.

@onready var dummy: CharacterBody2D = $Actors/Dummy
@onready var readout: Label = $Overlay/Health


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	readout.text = "Hero %d/%d   Dummy %d/%d   %s" % [player.health, player.max_health,
		dummy.health, dummy.max_health, _combat_status()]


func _unhandled_input(event: InputEvent) -> void:
	if not get_tree().paused and event.is_action_pressed("test_hit"):
		get_viewport().set_input_as_handled()
		dummy.trigger_strike()
	elif not get_tree().paused and event.is_action_pressed("test_knockdown"):
		get_viewport().set_input_as_handled()
		dummy.trigger_strike(true)
	else:
		super._unhandled_input(event)


func reset_test() -> void:
	super.reset_test()
	dummy.reset()


func _combat_status() -> String:
	if player.health == 0:
		return "DEAD — R to reset"
	if player.reaction != player.Reaction.READY:
		return player.Reaction.keys()[player.reaction]
	if player.strike < 0:
		return ""
	var timing: Vector3 = player.strike_times[player.strike]
	var phase := "WINDUP"
	if player.attack_time >= timing.x:
		phase = "ACTIVE" if player.attack_time < timing.x + timing.y else "RECOVERY"
	return "%s %s" % ["AIR" if player.strike == 3 else "HIT %d" % (player.strike + 1), phase]
