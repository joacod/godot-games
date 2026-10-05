extends Area2D

var direction := Vector2.RIGHT
var weapon: SurvivorWeaponData
var damage: int
var remaining: float
var spent := false

func configure(data: SurvivorWeaponData, rank: int) -> void:
    weapon = data
    damage = ceili(data.rank_damage[rank - 1])
    remaining = data.lifetime

func _ready() -> void:
    body_entered.connect(_hit)
    var visual := (load(weapon.attack_scene) as PackedScene).instantiate()
    $Visual.add_child(visual)

func _physics_process(delta: float) -> void:
    if spent:
        return
    remaining -= delta
    if remaining <= 0:
        spent = true
        queue_free()
        return
    var destination := global_position + direction * weapon.projectile_speed * delta
    # Sweep the center as well as using Area overlap, so fast shots cannot skip
    # an enemy between physics ticks. Both paths share the same spent guard.
    var query := PhysicsRayQueryParameters2D.create(global_position, destination, 4)
    var hit := get_world_2d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        _hit(hit.collider)
    global_position = destination

func _hit(body: Node) -> void:
    if spent or not is_instance_valid(body) or not body.has_method("is_alive") or not body.is_alive():
        return
    spent = true
    body.get_node("Health").take_damage(damage)
    queue_free()
