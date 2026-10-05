extends CharacterBody2D

var target: CharacterBody2D
var content: SurvivorEnemyData
var flash_remaining := 0.0

signal died(enemy: CharacterBody2D)

func configure(data: SurvivorEnemyData) -> void:
    content = data
    $Health.configure(content.max_health, 0.0)
    $Health.damaged.connect(_on_damage)
    $Health.died.connect(_on_death)

func is_alive() -> bool:
    return $Health.current > 0 and not is_queued_for_deletion()

func _on_damage(_amount: int, _remaining: int) -> void:
    flash_remaining = 0.12
    $Visual.modulate = Color(2, 2, 2, 1)

func _on_death() -> void:
    velocity = Vector2.ZERO
    collision_layer = 0
    set_physics_process(false)
    died.emit(self)
    queue_free()

func _physics_process(delta: float) -> void:
    flash_remaining = maxf(0.0, flash_remaining - delta)
    $Visual.modulate = Color(2, 2, 2, 1) if flash_remaining > 0 else Color.WHITE
    if not is_instance_valid(target) or target.get_node("Health").current == 0:
        velocity = Vector2.ZERO
        return
    var direction := global_position.direction_to(target.global_position)
    velocity = direction * content.speed
    if not direction.is_zero_approx():
        $Visual.rotation = direction.angle() + PI / 2.0
    move_and_slide()

func get_contact_damage() -> int:
    return content.contact_damage if is_alive() else 0
