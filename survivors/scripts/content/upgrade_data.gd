class_name SurvivorUpgradeData
extends Resource

enum Kind { WEAPON, PASSIVE, RECOVERY, POWER, REACH, EVOLUTION }

@export var id: StringName
@export var display_name: String
@export var description: String
@export_file("*.tscn") var icon_scene: String
@export var kind: Kind = Kind.WEAPON
@export var target_id: StringName
@export var max_rank: int = 1
@export var modifier: float = 0.0
@export var required_weapon_id: StringName
@export var required_weapon_rank: int = 0
@export var required_passive_id: StringName
@export var replacement_id: StringName
@export var chain_limit: int = 0
