extends "res://scripts/combat_actor.gd"
## Stationary receiver with a manually triggered, visible incoming strike.

var incoming_time: float = -1.0
var incoming_knockdown: bool = false
var _hit_targets: Dictionary = {}


func _ready() -> void:
	super._ready()
	_facing = -1.0


func trigger_strike(knockdown: bool = false) -> void:
	if reaction == Reaction.READY and incoming_time < 0.0:
		incoming_time = 0.0
		incoming_knockdown = knockdown
		_hit_targets.clear()


func _physics_process(delta: float) -> void:
	tick_reaction(delta)
	update_reaction_visual()
	if reaction != Reaction.READY:
		return
	if incoming_time >= 0.0:
		incoming_time += delta
		sprite.animation = &"attack"
		sprite.pause()
		sprite.frame = mini(5, int(incoming_time / 0.1))
		if incoming_time >= 0.4 and incoming_time < 0.5:
			strike_targets(_facing, 64.0, 14.0, 8.0, 15, incoming_knockdown, _hit_targets)
		if incoming_time >= 0.7:
			cancel_attack()
	else:
		sprite.play(&"idle")


func cancel_attack() -> void:
	incoming_time = -1.0
	_hit_targets.clear()


func reset() -> void:
	super.reset()
	_facing = -1.0
	update_reaction_visual()
	sprite.play(&"idle")
