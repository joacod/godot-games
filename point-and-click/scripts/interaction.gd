extends Node

signal hover_changed(display_name: String)
signal feedback_changed(text: String)
signal verb_changed(verb: String)

var selected_verb := "look"
var modal_open := false:
	set(value):
		modal_open = value
		_update_hover("")
var content: Dictionary = {}
var hotspots: Node2D
var hovered_name := ""
var pointer_position := Vector2.ZERO


func configure(bundle: Dictionary, regions: Node2D) -> void:
	content = bundle
	hotspots = regions


func select_verb(verb: String) -> void:
	if verb in ["look", "use", "talk"] and not modal_open:
		selected_verb = verb
		verb_changed.emit(verb)


func target_at(world_point: Vector2) -> String:
	if modal_open or hotspots == null:
		return ""
	# The first matching definition in room.json wins; physics picking order is unused.
	for hotspot in hotspots.get_children():
		if hotspot.contains_point(world_point):
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
	# Step 02 supports text-only, unconditional rules. Transactions and dialogue
	# belong to later steps; never partially execute a rule with other effects.
	for rule in content.puzzle.rules:
		if rule.verb != selected_verb or rule.target_id != target_id or rule.item_id != "":
			continue
		if not rule.requires.is_empty() or rule.effects.is_empty():
			continue
		var text_only := true
		var lines := PackedStringArray()
		for effect in rule.effects:
			if effect.type != "show_text":
				text_only = false
			else:
				lines.append(effect.text)
		if text_only:
			feedback_changed.emit("\n".join(lines))
			return
	feedback_changed.emit(content.puzzle.failure_responses[selected_verb])


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


func _unhandled_input(event: InputEvent) -> void:
	if modal_open or hotspots == null:
		return
	if event.is_action_pressed("interact"):
		dispatch(target_at(hotspots.get_canvas_transform().affine_inverse() * pointer_position))
		get_viewport().set_input_as_handled()
