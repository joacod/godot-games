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
    $Enemy.content = content.enemies[0]
    $Enemy.target = $Player
    _attach_visual($Arena/Visual, presentation.arena_visual_scene, presentation.floor_color)
    for edge in [$Arena/TopEdge, $Arena/BottomEdge, $Arena/LeftEdge, $Arena/RightEdge]:
        edge.color = presentation.boundary_color
    _attach_visual($Player/Visual, content.character.visual_scene, presentation.player_color)
    _attach_visual($Enemy/Visual, content.enemies[0].visual_scene, presentation.enemy_color)
    $Player/Label.text = content.character.display_name
    $Enemy/Label.text = content.enemies[0].display_name

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
    $Enemy.velocity = Vector2.ZERO
    # Keep the final hit readable, but freeze pursuit and movement on defeat.
    $Enemy.set_physics_process(false)
    defeated.emit()
