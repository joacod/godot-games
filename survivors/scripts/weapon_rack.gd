extends Node

const PROJECTILE = preload("res://scenes/attacks/projectile.tscn")
const ORBIT = preload("res://scenes/attacks/orbit.tscn")
const PULSE = preload("res://scenes/attacks/pulse.tscn")

var actor: CharacterBody2D
var attacks: Node2D
var enemies: Node2D
var equipped: Array[SurvivorWeaponData] = []
var cooldowns: Array[float] = []
var ranks: Array[int] = []
var orbits: Dictionary = {}
var slot_ids: Array[StringName] = []
var chain_limits: Dictionary = {}
var power_bonus := 0.0

func equip(weapon: SurvivorWeaponData, rank: int = 1) -> void:
    equipped.append(weapon)
    slot_ids.append(weapon.id)
    ranks.append(rank)
    cooldowns.append(weapon.cadence)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(actor) or actor.get_node("Health").current == 0:
        return
    for index in equipped.size():
        var weapon := equipped[index]
        if weapon.behavior == SurvivorWeaponData.Behavior.ORBIT:
            if not is_instance_valid(orbits.get(index)):
                var orbit := ORBIT.instantiate()
                orbit.actor = actor
                orbit.configure(weapon, ranks[index])
                orbit.damage = damage_for(index)
                attacks.add_child(orbit)
                orbits[index] = orbit
            elif orbits[index].remaining <= delta * 2.0:
                # Renew the equipped orbit without resetting per-target immunity.
                orbits[index].remaining += weapon.lifetime
            continue
        cooldowns[index] -= delta
        if cooldowns[index] > 0.00001:
            continue
        cooldowns[index] += weapon.cadence
        match weapon.behavior:
            SurvivorWeaponData.Behavior.NEAREST_SHOT:
                var nearest: CharacterBody2D
                var distance := INF
                for enemy in enemies.get_children():
                    if not enemy.is_alive():
                        continue
                    var candidate: float = actor.global_position.distance_squared_to(enemy.global_position)
                    if candidate < distance:
                        nearest = enemy
                        distance = candidate
                if is_instance_valid(nearest):
                    _shoot(index, actor.global_position.direction_to(nearest.global_position))
            SurvivorWeaponData.Behavior.CARDINAL_BURST:
                for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
                    _shoot(index, direction)
            SurvivorWeaponData.Behavior.PULSE:
                var pulse := PULSE.instantiate()
                pulse.configure(weapon, ranks[index])
                pulse.damage = damage_for(index)
                attacks.add_child(pulse)
                pulse.global_position = actor.global_position

func _shoot(index: int, direction: Vector2) -> void:
    var weapon := equipped[index]
    var rank := ranks[index]
    var projectile := PROJECTILE.instantiate()
    projectile.direction = direction
    projectile.configure(weapon, rank)
    projectile.damage = damage_for(index)
    projectile.chain_limit = chain_limits.get(index, 1)
    projectile.enemies = enemies
    attacks.add_child(projectile)
    projectile.global_position = actor.global_position
    projectile.rotation = direction.angle()

func stop() -> void:
    set_physics_process(false)
    for attack in attacks.get_children():
        attack.set_physics_process(false)
        attack.queue_free()

func damage_for(index: int) -> int:
    var weapon := equipped[index]
    return ceili(weapon.rank_damage[ranks[index] - 1] + weapon.rank_damage[0] * power_bonus)

func refresh_orbits() -> void:
    for index in orbits:
        if is_instance_valid(orbits[index]):
            orbits[index].damage = damage_for(index)

func evolve(recipe: SurvivorUpgradeData) -> void:
    for index in equipped.size():
        if slot_ids[index] != recipe.required_weapon_id:
            continue
        slot_ids[index] = recipe.replacement_id
        chain_limits[index] = recipe.chain_limit
        for attack in attacks.get_children():
            if attack.weapon == equipped[index]:
                attack.set_physics_process(false)
                attack.queue_free()
