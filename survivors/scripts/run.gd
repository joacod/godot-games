extends Node2D

signal defeated
signal health_changed(remaining: int, maximum: int)

# Immutable content is assigned before entering the tree; actors own fresh state.
var ended := false
var content: SurvivorRunData
var presentation: SurvivorThemeData

func _ready() -> void:
    $Player.speed = content.character.speed
    $Player/Health.configure(content.character.max_health, content.damage_cooldown)
    $Player/Health.damaged.connect(_on_damage)
    $Player/Health.died.connect(_on_death)
    $XP.content = content
    $Upgrades.content = content
    $Upgrades.rack = $Player/WeaponRack
    $Upgrades.health = $Player/Health
    $Upgrades.pickup_radius = content.pickup_radius
    $Enemies/Enemy.configure(content.enemies[0])
    watch_enemy($Enemies/Enemy)
    $Enemies/Enemy.target = $Player
    _attach_visual($Arena/Visual, presentation.arena_visual_scene, presentation.floor_color)
    for edge in [$Arena/TopEdge, $Arena/BottomEdge, $Arena/LeftEdge, $Arena/RightEdge]:
        edge.color = presentation.boundary_color
    _attach_visual($Player/Visual, content.character.visual_scene, presentation.player_color)
    _attach_visual($Enemies/Enemy/Visual, content.enemies[0].visual_scene, presentation.enemy_color)
    $Player/Label.text = content.character.display_name
    $Enemies/Enemy/Label.text = content.enemies[0].display_name

    $Player/WeaponRack.actor = $Player
    $Player/WeaponRack.attacks = $Attacks
    $Player/WeaponRack.enemies = $Enemies
    for weapon in content.weapons:
        if weapon.id == content.starting_weapon_id:
            $Player/WeaponRack.equip(weapon)

func _attach_visual(parent: Node2D, path: String, tint: Color) -> void:
    var visual := (load(path) as PackedScene).instantiate() as Node2D
    visual.modulate = tint
    parent.add_child(visual)

func _on_damage(_amount: int, remaining: int) -> void:
    health_changed.emit(remaining, content.character.max_health)

func _on_death() -> void:
    if ended:
        return
    ended = true
    $Player.velocity = Vector2.ZERO
    # Keep the final hit readable, but freeze pursuit and movement on defeat.
    for enemy in $Enemies.get_children():
        enemy.velocity = Vector2.ZERO
        enemy.set_physics_process(false)
    $Player/WeaponRack.stop()
    for gem in $Gems.get_children():
        gem.set_physics_process(false)
    defeated.emit()

func watch_enemy(enemy: CharacterBody2D) -> void:
    if not enemy.died.is_connected(_on_enemy_death):
        enemy.died.connect(_on_enemy_death, CONNECT_ONE_SHOT)

func _on_enemy_death(enemy: CharacterBody2D) -> void:
    if ended:
        return
    call_deferred("_drop_gem", enemy.global_position, enemy.content.xp_reward)

func _drop_gem(at: Vector2, amount: int) -> void:
    if ended or not is_inside_tree():
        return
    var gem := preload("res://scenes/xp_gem.tscn").instantiate()
    gem.actor = $Player
    gem.upgrades = $Upgrades
    gem.amount = amount
    gem.collected.connect(_grant_xp)
    $Gems.add_child(gem)
    gem.global_position = at

func _grant_xp(amount: int) -> void:
    if not ended:
        $XP.grant(amount)
