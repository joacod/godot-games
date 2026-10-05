extends Node2D

# Immutable content is assigned before entering the tree. No run state yet.
var content: SurvivorRunData
var presentation: SurvivorThemeData

func _ready() -> void:
    _attach_visual($Arena/Visual, presentation.arena_visual_scene, presentation.floor_color)
    for edge in [$Arena/TopEdge, $Arena/BottomEdge, $Arena/LeftEdge, $Arena/RightEdge]:
        edge.color = presentation.boundary_color
    _attach_visual($Player/Visual, content.character.visual_scene, presentation.player_color)
    _attach_visual($EnemyMarker/Visual, content.enemies[0].visual_scene, presentation.enemy_color)
    $Player/Label.text = content.character.display_name
    $EnemyMarker/Label.text = content.enemies[0].display_name

func _attach_visual(parent: Node2D, path: String, tint: Color) -> void:
    var visual := (load(path) as PackedScene).instantiate() as Node2D
    visual.modulate = tint
    parent.add_child(visual)
