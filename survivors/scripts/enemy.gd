extends CharacterBody2D

var target: CharacterBody2D
var content: SurvivorEnemyData

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(target) or target.get_node("Health").current == 0:
        velocity = Vector2.ZERO
        return
    var direction := global_position.direction_to(target.global_position)
    velocity = direction * content.speed
    if not direction.is_zero_approx():
        $Visual.rotation = direction.angle() + PI / 2.0
    move_and_slide()

func get_contact_damage() -> int:
    return content.contact_damage
