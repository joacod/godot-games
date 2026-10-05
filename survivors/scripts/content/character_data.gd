class_name SurvivorCharacterData
extends Resource

@export var id: StringName
@export var display_name: String
@export var max_health: int = 100
@export var speed: float = 150.0
@export_file("*.tscn") var visual_scene: String
