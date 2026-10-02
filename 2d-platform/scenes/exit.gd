extends Area2D

signal reached

@export var unlocked: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_marker()

func _on_body_entered(body) -> void:
	if not unlocked or get_tree().paused or not body.has_method("take_damage") or body.is_dead:
		return
	reached.emit()

func unlock() -> void:
	unlocked = true
	_update_marker()

func _update_marker() -> void:
	$WayOut.visible = unlocked
	$Opening.color = Color(0.12, 0.38, 0.36) if unlocked else Color(0.13, 0.16, 0.18)
	$Label.text = "EXIT" if unlocked else "SEALED"
