extends Area2D

signal reached

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if get_tree().paused or not body.has_method("take_damage") or body.is_dead:
		return
	reached.emit()
