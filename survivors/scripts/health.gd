extends Node

signal damaged(amount: int, remaining: int)
signal died

var maximum: int
var current: int
var damage_cooldown: float
var invulnerability_remaining := 0.0

func configure(max_health: int, cooldown: float) -> void:
    maximum = max_health
    current = maximum
    damage_cooldown = cooldown
    invulnerability_remaining = 0.0

func _physics_process(delta: float) -> void:
    invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)

func take_damage(amount: int) -> bool:
    if amount <= 0 or current == 0 or invulnerability_remaining > 0.00001:
        return false
    var previous := current
    current = maxi(0, current - amount)
    invulnerability_remaining = damage_cooldown
    damaged.emit(previous - current, current)
    if current == 0:
        died.emit()
    return true
