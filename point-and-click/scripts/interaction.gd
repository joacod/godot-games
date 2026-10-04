extends Node

signal hover_changed(display_name: String)
signal feedback_changed(text: String)
signal verb_changed(verb: String)
signal selection_changed(item_id: String)

var selected_item := ""
var inventory: Node
var puzzle_state: Node

var selected_verb := "look"
var modal_open := false:
	set(value):
		modal_open = value
		_update_hover("")
var content: Dictionary = {}
var hotspots: Node2D
var hovered_name := ""
var pointer_position := Vector2.ZERO


func configure(bundle: Dictionary, regions: Node2D, item_store: Node, state: Node) -> void:
	inventory = item_store
	puzzle_state = state
	inventory.changed.connect(_refresh_selection)
	content = bundle
	hotspots = regions


func select_verb(verb: String) -> void:
	if verb in ["look", "use", "talk"] and not modal_open:
		cancel_selection()
		selected_verb = verb
		verb_changed.emit(verb)


func target_at(world_point: Vector2) -> String:
	if modal_open or hotspots == null:
		return ""
	# The first matching definition in room.json wins; physics picking order is unused.
	for hotspot in hotspots.get_children():
		if hotspot.visible and hotspot.contains_point(world_point):
			return hotspot.hotspot_id
	return ""


func dispatch(target_id: String) -> void:
	if modal_open or target_id.is_empty() or content.is_empty():
		return
	var known_target := false
	for definition in content.room.hotspots:
		if definition.id == target_id:
			known_target = true
	if not known_target:
		return
	var failed_text := ""
	for rule in content.puzzle.rules:
		if rule.verb != selected_verb or rule.target_id != target_id or rule.item_id != selected_item:
			continue
		if not puzzle_state.supports(rule):
			continue
		if not puzzle_state.conditions_met(rule.requires):
			if failed_text.is_empty():
				failed_text = rule.failure_text
			continue
		var result: Dictionary = puzzle_state.apply(rule)
		if result.capacity or not result.text.is_empty():
			feedback_changed.emit(content.puzzle.failure_responses.capacity if result.capacity else result.text)
		return
	feedback_changed.emit(failed_text if not failed_text.is_empty() else content.puzzle.failure_responses[selected_verb])


func select_item(item_id: String) -> void:
	if modal_open or item_id not in inventory.items:
		return
	selected_verb = "use"
	selected_item = item_id
	verb_changed.emit(selected_verb)
	selection_changed.emit(selected_item)


func cancel_selection() -> void:
	selected_item = ""
	selection_changed.emit(selected_item)


func _refresh_selection() -> void:
	if selected_item not in inventory.items:
		cancel_selection()


func _process(_delta: float) -> void:
	var display_name := ""
	if not modal_open and hotspots != null and get_viewport().gui_get_hovered_control() == null:
		var target := target_at(hotspots.get_canvas_transform().affine_inverse() * pointer_position)
		for hotspot in hotspots.get_children():
			if hotspot.hotspot_id == target:
				display_name = hotspot.display_name
	_update_hover(display_name)


func _update_hover(display_name: String) -> void:
	if hovered_name != display_name:
		hovered_name = display_name
		hover_changed.emit(display_name)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		pointer_position = event.position
	if event.is_action_pressed("cancel") and not modal_open and not selected_item.is_empty():
		cancel_selection()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if modal_open or hotspots == null:
		return
	if event.is_action_pressed("interact"):
		dispatch(target_at(hotspots.get_canvas_transform().affine_inverse() * pointer_position))
		get_viewport().set_input_as_handled()
