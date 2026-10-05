class_name SurvivorWeaponData
extends Resource

enum Behavior { NEAREST_SHOT, ORBIT, PULSE, CARDINAL_BURST }

@export var id: StringName
@export var display_name: String
@export var behavior: Behavior = Behavior.NEAREST_SHOT
@export var rank_damage: PackedFloat32Array
@export var cadence: float = 0.7
@export var radius: float = 0.0
@export var projectile_speed: float = 0.0
@export var lifetime: float = 1.0
@export_file("*.tscn") var attack_scene: String
