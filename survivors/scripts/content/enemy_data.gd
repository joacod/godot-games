class_name SurvivorEnemyData
extends Resource

@export var id: StringName
@export var display_name: String
@export var max_health: int = 20
@export var speed: float = 45.0
@export var contact_damage: int = 10
@export var xp_reward: int = 5
@export var elite: bool = false
@export_file("*.tscn") var visual_scene: String
