extends Area2D

signal collected(amount: int)

var actor: CharacterBody2D
var upgrades: Node
var amount: int
var attracted := false
var spent := false

func _physics_process(delta: float) -> void:
    if spent or not is_instance_valid(actor) or actor.get_node("Health").current == 0:
        return
    var distance := global_position.distance_to(actor.global_position)
    if distance <= upgrades.pickup_radius:
        attracted = true
    if attracted:
        global_position = global_position.move_toward(actor.global_position, 240.0 * delta)
        if global_position.distance_to(actor.global_position) <= 12.0:
            collect()

func collect() -> void:
    if spent or not actor.get_node("Health").active or get_tree().paused or actor.get_node("Health").current == 0:
        return
    spent = true
    hide()
    collected.emit(amount)
    queue_free()
