class_name SurvivorRunData
extends Resource

@export var duration: float = 180.0
@export var arena_size: Vector2 = Vector2(960, 640)
@export var ordinary_cap: int = 60
@export var first_level_xp: int = 10
@export var level_xp_increment: int = 5
@export var starting_weapon_id: StringName = &"spark"
@export var damage_cooldown: float = 0.7
@export var pickup_radius: float = 48.0
@export var elite_spawn_seconds: float = 120.0
@export var character: SurvivorCharacterData
@export var weapons: Array[SurvivorWeaponData]
@export var enemies: Array[SurvivorEnemyData]
@export var upgrades: Array[SurvivorUpgradeData]
@export var spawn_phases: Array[SurvivorSpawnPhaseData]
