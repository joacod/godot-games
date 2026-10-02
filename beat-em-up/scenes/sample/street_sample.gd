extends Node2D
## Art preview only: actors stay at their ground anchors throughout the cycle.

const HERO_ANIMATIONS: Array[StringName] = [
	&"idle", &"move", &"attack_1", &"attack_2", &"attack_3"
]
const ENEMY_ANIMATIONS: Array[StringName] = [
	&"idle", &"move", &"attack", &"attack", &"attack"
]

@onready var hero: AnimatedSprite2D = $Actors/Hero/Visual/Sprite
@onready var enemy: AnimatedSprite2D = $Actors/Enemy/Visual/Sprite
@onready var caption: Label = $Overlay/Caption

var _preview_index: int = 0


func _ready() -> void:
	_show_preview()


func _on_preview_timer_timeout() -> void:
	_preview_index = (_preview_index + 1) % HERO_ANIMATIONS.size()
	_show_preview()


func _show_preview() -> void:
	hero.stop()
	enemy.stop()
	hero.play(HERO_ANIMATIONS[_preview_index])
	enemy.play(ENEMY_ANIMATIONS[_preview_index])
	caption.text = "BIKER: %s    /    SEAPORT: %s" % [
		HERO_ANIMATIONS[_preview_index], ENEMY_ANIMATIONS[_preview_index]
	]
