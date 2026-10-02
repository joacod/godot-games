extends Area2D

signal collected
var used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if used or get_tree().paused or not body.has_method("take_damage") or body.is_dead:
		return
	used = true
	collected.emit()
	hide()
	set_deferred("monitoring", false)
	queue_free()
