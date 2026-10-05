extends Area2D

var actor: CharacterBody2D
var weapon: SurvivorWeaponData
var damage: int
var remaining: float
var angle := 0.0
var elapsed := 0.0
var next_hit: Dictionary = {}

func configure(data: SurvivorWeaponData, rank: int) -> void:
    weapon = data
    damage = ceili(data.rank_damage[rank - 1])
    remaining = data.lifetime

func _ready() -> void:
    $Visual.add_child((load(weapon.attack_scene) as PackedScene).instantiate())
    global_position = actor.global_position + Vector2.RIGHT * weapon.radius

func _physics_process(delta: float) -> void:
    remaining -= delta
    if remaining <= 0 or not is_instance_valid(actor) or actor.get_node("Health").current == 0:
        queue_free()
        return
    elapsed += delta
    angle += TAU * delta / weapon.lifetime
    global_position = actor.global_position + Vector2.from_angle(angle) * weapon.radius
    for body in get_overlapping_bodies():
        if not body.has_method("is_alive") or not body.is_alive():
            continue
        var id := body.get_instance_id()
        if elapsed + 0.00001 >= next_hit.get(id, 0.0):
            next_hit[id] = elapsed + weapon.cadence
            body.get_node("Health").take_damage(damage)
