extends Node
## Owns one whole run and the minimal keyboard/controller menu flow.

const STREET = preload("res://scenes/level/street.tscn")
enum State { TITLE, CONTROLS, PLAYING, PAUSED, DEAD, VICTORY }
var state: State = State.TITLE
var street: Node2D
var overlay: CanvasLayer
var panel: PanelContainer
var items: VBoxContainer
var heading: Label
var hud: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = CanvasLayer.new()
	add_child(overlay)
	hud = Label.new()
	hud.position = Vector2(16, 8)
	hud.size = Vector2(608, 56)
	hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud.add_theme_font_size_override("font_size", 14)
	var header := ColorRect.new()
	header.size = Vector2(640, 70)
	header.color = Color(0.04, 0.06, 0.09, 0.92)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(header)
	overlay.add_child(hud)
	panel = PanelContainer.new()
	panel.position = Vector2(120, 60)
	panel.size = Vector2(400, 250)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.09, 0.97)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	items = VBoxContainer.new()
	items.add_theme_constant_override("separation", 8)
	panel.add_child(items)
	_show_menu(State.TITLE)


func _process(_delta: float) -> void:
	if is_instance_valid(street):
		hud.text = "HERO %d/%d    %s\nEscape / Start: pause" % [street.player.health,
			street.player.max_health, street.prompt]
		if is_instance_valid(street.boss):
			hud.text = "HERO %d/%d    BOSS %d/%d\n%s" % [street.player.health,
				street.player.max_health, street.boss.health, street.boss.max_health, street.prompt]


func _show_menu(next_state: State) -> void:
	state = next_state
	get_tree().paused = state in [State.PAUSED, State.DEAD, State.VICTORY]
	for child in items.get_children():
		items.remove_child(child)
		child.queue_free()
	panel.show()
	heading = Label.new()
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.text = {State.TITLE: "BEAT 'EM UP", State.CONTROLS: "CONTROLS",
		State.PAUSED: "PAUSED", State.DEAD: "GAME OVER", State.VICTORY: "VICTORY"}[state]
	items.add_child(heading)
	match state:
		State.TITLE:
			_button("Play", start_run)
			_button("Controls", func() -> void: _show_menu(State.CONTROLS))
			_button("Quit", func() -> void: get_tree().quit())
		State.CONTROLS:
			var controls := Label.new()
			controls.text = "Move: WASD/arrows / stick or D-pad\nAttack: J / west   Jump: Space / south\nPause: Escape / Start\nMenus: arrows/D-pad, Enter/south, Esc/east"
			controls.add_theme_font_size_override("font_size", 13)
			items.add_child(controls)
			_button("Back", main_menu)
		State.PAUSED, State.DEAD, State.VICTORY:
			if state == State.PAUSED:
				_button("Resume", resume_run)
			_button("Play Again" if state == State.VICTORY else "Retry", start_run)
			_button("Main Menu", main_menu)
			_button("Quit", func() -> void: get_tree().quit())
	for child in items.get_children():
		if child is Button:
			child.grab_focus()
			break


func _button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.pressed.connect(action)
	items.add_child(button)


func _remove_run() -> void:
	get_tree().paused = false
	if is_instance_valid(street):
		remove_child(street)
		street.queue_free()
	street = null
	hud.text = ""


func start_run() -> void:
	_remove_run()
	street = STREET.instantiate()
	add_child(street)
	street.hero_died.connect(_finish_run.bind(State.DEAD))
	street.won.connect(_finish_run.bind(State.VICTORY))
	state = State.PLAYING
	panel.hide()
	street.player.require_input_release()


func _finish_run(result: State) -> void:
	if state not in [State.PLAYING, State.PAUSED]:
		return
	_show_menu(State.DEAD if street.player.health == 0 else result)


func main_menu() -> void:
	_remove_run()
	_show_menu(State.TITLE)


func resume_run() -> void:
	state = State.PLAYING
	get_tree().paused = false
	panel.hide()
	street.player.require_input_release()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and state == State.PLAYING:
		get_viewport().set_input_as_handled()
		_show_menu(State.PAUSED)
	elif (event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")) \
			and state == State.PAUSED:
		get_viewport().set_input_as_handled()
		resume_run()
	elif event.is_action_pressed("ui_cancel") and state == State.CONTROLS:
		get_viewport().set_input_as_handled()
		main_menu()
