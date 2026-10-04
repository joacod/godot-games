extends Control

signal start_requested
signal resume_requested
signal restart_requested
signal pause_requested

var screen := ""


func _ready() -> void:
	$Panel/Margin/Rows/Primary.pressed.connect(_primary)
	$Panel/Margin/Rows/Restart.pressed.connect(func(): restart_requested.emit())
	$Pause.pressed.connect(func(): pause_requested.emit())
	$Pause.text = theme.get_meta("menu_pause_button")
	$Panel/Margin/Rows/Restart.text = theme.get_meta("menu_restart")


func show_screen(value: String) -> void:
	screen = value
	mouse_filter = Control.MOUSE_FILTER_IGNORE if screen.is_empty() else Control.MOUSE_FILTER_STOP
	$Shade.visible = not screen.is_empty()
	$Panel.visible = not screen.is_empty()
	$Pause.visible = screen.is_empty()
	if screen.is_empty():
		return
	$Panel/Margin/Rows/Title.text = theme.get_meta("menu_" + screen + "_title")
	$Panel/Margin/Rows/Text.text = theme.get_meta("menu_" + screen + "_text")
	$Panel/Margin/Rows/Primary.visible = screen != "complete"
	$Panel/Margin/Rows/Primary.text = theme.get_meta("menu_start" if screen == "start" else "menu_resume")
	$Panel/Margin/Rows/Restart.visible = screen != "start"
	if screen == "complete":
		$Panel/Margin/Rows/Restart.grab_focus()
	else:
		$Panel/Margin/Rows/Primary.grab_focus()


func _primary() -> void:
	if screen == "start":
		start_requested.emit()
	elif screen == "pause":
		resume_requested.emit()


func _input(event: InputEvent) -> void:
	if screen == "pause" and event.is_action_pressed("pause"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()
