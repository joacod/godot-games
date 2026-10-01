extends Node


# Falling past this horizontal line is lethal at any x position.
@export var fall_kill_y = 1120.0
enum RunState {PLAYING, DEAD, RETRYING}
var state = RunState.PLAYING
@onready var character = $CharacterBody2D
@onready var death_ui = $DeathUI

func _ready():
	character.died.connect(_on_player_died)
	death_ui.get_node("Overlay/Panel/Buttons/Retry").pressed.connect(retry)
	death_ui.get_node("Overlay/Panel/Buttons/Quit").pressed.connect(_quit)

func _physics_process(_delta):
	if state == RunState.PLAYING and character.global_position.y > fall_kill_y:
		character.kill()

func _on_player_died():
	if state != RunState.PLAYING:
		return
	state = RunState.DEAD
	get_tree().paused = true
	death_ui.show()
	death_ui.get_node("Overlay/Panel/Buttons/Retry").grab_focus()

func retry():
	if state != RunState.DEAD:
		return
	state = RunState.RETRYING
	# Reload outside physics callbacks, replacing the entire run, not just the player.
	_reload_level.call_deferred()

func _reload_level():
	# Reload detaches this node immediately; retain the tree before that happens.
	var tree = get_tree()
	var error = tree.reload_current_scene()
	if error != OK:
		state = RunState.DEAD
		push_error("Could not reload the level: %s" % error)
		return
	tree.paused = false

func _quit():
	get_tree().quit()
