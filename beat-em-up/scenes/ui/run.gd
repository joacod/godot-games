extends Node
## Owns one whole run, its HUD, and keyboard/controller menus.

const STREET = preload("res://scenes/level/street.tscn")
const AUDIO = preload("res://scenes/ui/audio.gd")
const INK := Color(0.035, 0.055, 0.08, 0.97)
const TEAL := Color(0.4, 0.95, 0.85)
const AMBER := Color(1.0, 0.8, 0.4)
enum State { TITLE, CONTROLS, PLAYING, PAUSED, DEAD, VICTORY, AUDIO }
var state: State = State.TITLE
var street: Node2D
var overlay: CanvasLayer
var panel: PanelContainer
var items: VBoxContainer
var heading: Label
var hud: Label
var hero_health: Label
var hero_bar: ProgressBar
var boss_health: Label
var boss_bar: ProgressBar
var hud_panel: Control
var menu_background: Control
var menu_hint: Label
var audio: Node
var menu_return: State = State.TITLE
var _building_menu: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio = AUDIO.new()
	add_child(audio)
	overlay = CanvasLayer.new()
	add_child(overlay)
	_build_backdrop()
	_build_hud()
	panel = PanelContainer.new()
	panel.position = Vector2(120, 38)
	panel.size = Vector2(400, 282)
	panel.add_theme_stylebox_override("panel", _style(INK, Color(0.2, 0.4, 0.43), 16))
	overlay.add_child(panel)
	items = VBoxContainer.new()
	items.add_theme_constant_override("separation", 6)
	panel.add_child(items)
	menu_hint = Label.new()
	menu_hint.position = Vector2(16, 328)
	menu_hint.size = Vector2(608, 24)
	menu_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_hint.add_theme_font_size_override("font_size", 12)
	menu_hint.add_theme_color_override("font_color", TEAL)
	overlay.add_child(menu_hint)
	_show_menu(State.TITLE)


func _style(fill: Color, border: Color, margin: float = 0.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style


func _build_backdrop() -> void:
	menu_background = Control.new()
	menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(menu_background)
	var city := TextureRect.new()
	city.texture = preload("res://assets/street/city.png")
	city.position = Vector2(0, -60)
	city.size = Vector2(640, 360)
	city.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	city.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_background.add_child(city)
	var shade := ColorRect.new()
	shade.size = Vector2(640, 360)
	shade.color = Color(0.02, 0.035, 0.05, 0.6)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_background.add_child(shade)


func _build_hud() -> void:
	hud_panel = Control.new()
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(hud_panel)
	var header := ColorRect.new()
	header.size = Vector2(640, 84)
	header.color = Color(0.025, 0.045, 0.065, 0.92)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_panel.add_child(header)
	hero_health = _hud_label(Vector2(16, 8), Vector2(250, 22))
	hero_bar = _health_bar(Vector2(16, 32), TEAL)
	boss_health = _hud_label(Vector2(370, 8), Vector2(254, 22))
	boss_health.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boss_bar = _health_bar(Vector2(420, 32), AMBER)
	hud = _hud_label(Vector2(16, 52), Vector2(608, 28))
	hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_theme_font_size_override("font_size", 13)


func _hud_label(pos: Vector2, dimensions: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	label.add_theme_font_size_override("font_size", 14)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_panel.add_child(label)
	return label


func _health_bar(pos: Vector2, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.show_percentage = false
	bar.add_theme_font_size_override("font_size", 1)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _style(Color(0.1, 0.15, 0.18), Color(0.24, 0.32, 0.35)))
	bar.add_theme_stylebox_override("fill", _style(color, color))
	hud_panel.add_child(bar)
	bar.size = Vector2(204, 10)
	return bar


func _process(_delta: float) -> void:
	if is_instance_valid(street):
		hero_health.text = "BIKER  %d / %d" % [street.player.health, street.player.max_health]
		hero_bar.max_value = street.player.max_health
		hero_bar.value = street.player.health
		hud.text = street.prompt
		var has_boss := is_instance_valid(street.boss)
		boss_health.visible = true
		boss_bar.visible = has_boss
		if has_boss:
			boss_health.text = "TOXIC ENFORCER  %d / %d" % [street.boss.health, street.boss.max_health]
			boss_bar.max_value = street.boss.max_health
			boss_bar.value = street.boss.health
		else:
			boss_health.text = "Escape / Start · Pause"


func _show_menu(next_state: State) -> void:
	state = next_state
	get_tree().paused = is_instance_valid(street)
	audio.set_playing(false)
	_building_menu = true
	for child in items.get_children():
		items.remove_child(child)
		child.queue_free()
	panel.show()
	menu_background.visible = not is_instance_valid(street)
	hud_panel.visible = is_instance_valid(street)
	menu_hint.show()
	menu_hint.text = "↑↓ / D-pad: choose   Enter / south: confirm   Esc / east: back"
	if state in [State.TITLE, State.DEAD, State.VICTORY]:
		menu_hint.text = "↑↓ / D-pad: choose   Enter / south: confirm"
	heading = Label.new()
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", AMBER)
	heading.text = {State.TITLE: "BEAT 'EM UP", State.CONTROLS: "CONTROLS",
		State.PAUSED: "PAUSED", State.DEAD: "GAME OVER", State.VICTORY: "STREET CLEARED", State.AUDIO: "AUDIO"}[state]
	items.add_child(heading)
	match state:
		State.TITLE:
			_button("Play", start_run)
			_button("Controls", func() -> void: _open_submenu(State.CONTROLS))
			_button("Audio", func() -> void: _open_submenu(State.AUDIO))
			_button("Quit", func() -> void: get_tree().quit())
			_note("One street. Two fights. One final boss.")
		State.CONTROLS:
			_note("Move     WASD / arrows · stick / D-pad\nAttack   J · west face button\nJump     Space · south face button\nPause    Escape · Start\n\nTap Attack late in a punch to chain up to 3.\nJump, then Attack for an air kick.\nChange street depth to dodge enemy tells.")
			_button("Back", _back)
		State.AUDIO:
			for bus in [&"Master", &"Music", &"SFX"]:
				_volume_row(bus)
			_button("Back", _back)
			_note("←→ / D-pad: volume · 0% mutes\nMusic continues quietly while paused.")
		State.PAUSED, State.DEAD, State.VICTORY:
			if state == State.PAUSED:
				_button("Resume", resume_run)
			_button("Play Again" if state == State.VICTORY else "Retry", start_run)
			if state == State.PAUSED:
				_button("Audio", func() -> void: _open_submenu(State.AUDIO))
			_button("Main Menu", main_menu)
			_button("Quit", func() -> void: get_tree().quit())
			if state != State.PAUSED:
				_note("The yard is yours. Thanks for playing." if state == State.VICTORY else "A fresh run restores health and the whole street.")
	var focusables: Array[Control] = []
	for child in items.get_children():
		if child is Button:
			focusables.append(child)
		elif child is HBoxContainer:
			focusables.append(child.get_node("Volume"))
	for index in range(focusables.size()):
		var control := focusables[index]
		control.focus_neighbor_top = control.get_path_to(focusables[posmod(index - 1, focusables.size())])
		control.focus_neighbor_bottom = control.get_path_to(focusables[(index + 1) % focusables.size()])
	focusables[0].grab_focus()
	_building_menu = false


func _note(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.75, 0.83, 0.86))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	items.add_child(label)


func _focus_sound() -> void:
	if not _building_menu:
		audio.play_menu(&"focus")


func _button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 32
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", _style(Color(0.07, 0.13, 0.16), Color(0.18, 0.3, 0.34)))
	button.add_theme_stylebox_override("hover", _style(Color(0.12, 0.23, 0.25), TEAL))
	button.add_theme_stylebox_override("pressed", _style(Color(0.15, 0.3, 0.31), AMBER))
	var focus := _style(Color(0.0, 0.0, 0.0, 0.0), AMBER)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.focus_entered.connect(_focus_sound)
	button.pressed.connect(func() -> void:
		audio.play_menu(&"confirm")
		action.call())
	items.add_child(button)


func _volume_row(bus: StringName) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 36
	items.add_child(row)
	var label := Label.new()
	label.text = "%s %d%%" % [bus, audio.volumes[bus]]
	label.custom_minimum_size.x = 116
	label.add_theme_font_size_override("font_size", 14)
	row.add_child(label)
	var slider := HSlider.new()
	slider.name = "Volume"
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.value = audio.volumes[bus]
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_entered.connect(_focus_sound)
	slider.focus_entered.connect(func() -> void:
		label.text = "> %s %d%%" % [bus, slider.value]
		label.add_theme_color_override("font_color", AMBER))
	slider.focus_exited.connect(func() -> void:
		label.text = "%s %d%%" % [bus, slider.value]
		label.remove_theme_color_override("font_color"))
	slider.value_changed.connect(func(value: float) -> void:
		audio.set_volume(bus, value)
		label.text = ("> " if slider.has_focus() else "") + "%s %d%%" % [bus, value]
		audio.play_menu(&"focus"))
	row.add_child(slider)


func _open_submenu(submenu: State) -> void:
	menu_return = state
	_show_menu(submenu)


func _back() -> void:
	_show_menu(menu_return)


func _remove_run() -> void:
	get_tree().paused = false
	audio.clear_game_sounds()
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
	street.get_node("Presentation").sound_requested.connect(audio.play_game)
	state = State.PLAYING
	panel.hide()
	menu_background.hide()
	menu_hint.hide()
	hud_panel.show()
	audio.set_playing(true)
	street.player.require_input_release()


func _finish_run(result: State) -> void:
	if state not in [State.PLAYING, State.PAUSED]:
		return
	audio.clear_game_sounds()
	_show_menu(State.DEAD if street.player.health == 0 else result)
	audio.play_menu(&"hurt" if state == State.DEAD else &"pickup")


func main_menu() -> void:
	_remove_run()
	_show_menu(State.TITLE)


func resume_run() -> void:
	state = State.PLAYING
	get_tree().paused = false
	panel.hide()
	menu_hint.hide()
	audio.set_playing(true)
	street.player.require_input_release()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and state == State.PLAYING:
		get_viewport().set_input_as_handled()
		audio.play_menu(&"confirm")
		_show_menu(State.PAUSED)
	elif (event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")) \
			and state == State.PAUSED:
		get_viewport().set_input_as_handled()
		resume_run()
	elif event.is_action_pressed("ui_cancel") and state in [State.CONTROLS, State.AUDIO]:
		get_viewport().set_input_as_handled()
		_back()
