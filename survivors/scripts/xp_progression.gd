extends Node

signal choices_needed
signal changed

var level := 1
var xp := 0
var pending_levels := 0
var content: SurvivorRunData

func threshold() -> int:
    return content.first_level_xp + (level - 1) * content.level_xp_increment

func grant(amount: int) -> void:
    if amount <= 0:
        return
    xp += amount
    while xp >= threshold():
        xp -= threshold()
        level += 1
        pending_levels += 1
    changed.emit()
    if pending_levels > 0:
        choices_needed.emit()

func choice_level() -> int:
    return level - pending_levels + 1

func resolve_level() -> void:
    pending_levels = maxi(0, pending_levels - 1)
    changed.emit()
