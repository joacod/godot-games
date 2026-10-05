extends Area2D

var weapon: SurvivorWeaponData
var damage: int
var remaining: float
var hit_targets: Dictionary = {}
var sampled := false

func configure(data: SurvivorWeaponData, rank: int) -> void:
    weapon = data
    damage = ceili(data.rank_damage[rank - 1])
    remaining = data.lifetime
    var shape := CircleShape2D.new()
    shape.radius = data.radius
    $CollisionShape2D.shape = shape

func _ready() -> void:
    $Visual.add_child((load(weapon.attack_scene) as PackedScene).instantiate())
    $Visual.scale = Vector2.ONE * weapon.radius

func _physics_process(delta: float) -> void:
    remaining -= delta
    if remaining <= 0:
        queue_free()
        return
    if not sampled:
        # Query explicitly on the first physics tick; a newly inserted Area's
        # cached overlaps may not yet describe the activation radius.
        var query := PhysicsShapeQueryParameters2D.new()
        query.shape = $CollisionShape2D.shape
        query.transform = global_transform
        query.collision_mask = 4
        for hit in get_world_2d().direct_space_state.intersect_shape(query, 128):
            var body: Node = hit.collider
            if body.has_method("is_alive") and body.is_alive() and not hit_targets.has(body.get_instance_id()):
                hit_targets[body.get_instance_id()] = true
                body.get_node("Health").take_damage(damage)
        sampled = true
    $Visual.modulate.a = maxf(0.0, 1.0 - (weapon.lifetime - remaining) / 0.3)
