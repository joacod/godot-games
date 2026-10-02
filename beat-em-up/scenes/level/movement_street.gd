extends Node2D
## Step 02 test owner: pause/reset and an X-only camera. No combat or run flow.

@onready var player: CharacterBody2D = $Actors/Player
@onready var camera: Camera2D = $Camera
@onready var pause_panel: Control = $Overlay/PausePanel


func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		_follow_player()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test_reset") \
			or (get_tree().paused and event.is_action_pressed("attack")):
		get_viewport().set_input_as_handled()
		reset_test()
	elif event.is_action_pressed("pause") \
			or (get_tree().paused and event.is_action_pressed("ui_accept")):
		get_viewport().set_input_as_handled()
		toggle_pause()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused
	if not get_tree().paused:
		player.require_input_release()


func reset_test() -> void:
	get_tree().paused = false
	pause_panel.hide()
	player.reset()
	_follow_player()
	camera.reset_smoothing()
	camera.force_update_scroll()


func _follow_player() -> void:
	camera.position.x = clampf(player.position.x, 320.0, 960.0)
