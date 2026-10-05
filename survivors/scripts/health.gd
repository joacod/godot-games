extends Node

signal damaged(amount: int, remaining: int)
signal died

var shield := 0
var maximum: int
var current: int
var damage_cooldown: float
var invulnerability_remaining := 0.0

func configure(max_health: int, cooldown: float) -> void:
    shield = 0
    maximum = max_health
    current = maximum
    damage_cooldown = cooldown
    invulnerability_remaining = 0.0

func _physics_process(delta: float) -> void:
    invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)

func take_damage(amount: int) -> bool:
    if (is_inside_tree() and get_tree().paused) or amount <= 0 or current == 0 or invulnerability_remaining > 0.00001:
        return false
    var previous := current
    var absorbed := mini(shield, amount)
    shield -= absorbed
    current = maxi(0, current - (amount - absorbed))
    invulnerability_remaining = damage_cooldown
    damaged.emit(previous - current, current)
    if current == 0:
        died.emit()
    return true

func recover(amount: int) -> void:
    if amount <= 0 or current == 0:
        return
    var healed := mini(amount, maximum - current)
    current += healed
    shield += amount - healed
