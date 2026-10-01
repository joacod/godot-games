extends Control


var starting = false
@onready var menu = $Center/Menu
@onready var help = $Center/Help

func _ready():
	menu.get_node("Play").pressed.connect(_play)
	menu.get_node("HowToPlay").pressed.connect(_show_help)
	menu.get_node("Quit").pressed.connect(_quit)
	help.get_node("Back").pressed.connect(_show_menu)
	menu.get_node("Play").grab_focus()

func _unhandled_input(event):
	if help.visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		_show_menu()
		get_viewport().set_input_as_handled()

func _show_help():
	menu.hide()
	help.show()
	help.get_node("Back").grab_focus()

func _show_menu():
	help.hide()
	menu.show()
	menu.get_node("HowToPlay").grab_focus()

func _play():
	if starting:
		return
	starting = true
	_start_level.call_deferred()

func _start_level():
	var error = get_tree().change_scene_to_file("res://main.tscn")
	if error != OK:
		starting = false
		push_error("Could not start the level: %s" % error)

func _quit():
	get_tree().quit()
