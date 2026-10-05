extends RefCounted

static func equip_all(run: Node2D) -> void:
    var rack := run.get_node("Player/WeaponRack")
    for weapon in run.content.weapons:
        if weapon.id != run.content.starting_weapon_id:
            rack.equip(weapon)

static func add_enemy(run: Node2D, at: Vector2, hp: int = 200) -> CharacterBody2D:
    var enemy := preload("res://scenes/enemy.tscn").instantiate()
    run.get_node("Enemies").add_child(enemy)
    enemy.configure(run.content.enemies[0])
    run.watch_enemy(enemy)
    enemy.get_node("Health").configure(hp, 0.0)
    enemy.target = run.get_node("Player")
    enemy.global_position = at
    run._attach_visual(enemy.get_node("Visual"), enemy.content.visual_scene, run.presentation.enemy_color)
    enemy.get_node("Label").text = enemy.content.display_name
    return enemy
