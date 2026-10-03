extends RefCounted

const FILES := ["room", "items", "dialogue", "puzzle"]
const VERBS := ["look", "use", "talk"]
var errors: PackedStringArray = []


func load_content(directory: String = "res://data") -> Dictionary:
	errors.clear()
	var content := {}
	for file_id in FILES:
		var path := directory.path_join(file_id + ".json")
		if not FileAccess.file_exists(path):
			fail(path, "file", "file is missing")
			continue
		var parsed = parse_document(FileAccess.get_file_as_string(path), path)
		if parsed is Dictionary:
			content[file_id] = parsed
	if errors.is_empty():
		validate(content)
	return {"content": content if errors.is_empty() else {}, "errors": errors.duplicate()}


func parse_document(source: String, path: String) -> Variant:
	var parser := JSON.new()
	if parser.parse(source) != OK:
		fail(path, "JSON", "line %d: %s" % [parser.get_error_line(), parser.get_error_message()])
		return null
	if not parser.data is Dictionary:
		fail(path, "root", "expected object")
		return null
	return parser.data


func fail(file: String, id: String, message: String) -> void:
	errors.append("%s [%s]: %s" % [file, id, message])


func shape(value: Variant, fields: Dictionary, file: String, id: String, optional: Array = []) -> bool:
	if not value is Dictionary:
		fail(file, id, "expected object")
		return false
	var valid := true
	for key in fields:
		if not value.has(key):
			if key not in optional:
				fail(file, id, "missing field '%s'" % key)
				valid = false
		elif typeof(value[key]) != fields[key]:
			fail(file, id, "invalid type for '%s'" % key)
			valid = false
		elif fields[key] == TYPE_STRING and key != "item_id" and value[key].strip_edges().is_empty():
			fail(file, id, "'%s' must not be empty" % key)
			valid = false
	for key in value:
		if not fields.has(key):
			fail(file, id, "unknown field '%s'" % key)
			valid = false
	return valid


func entries(values: Array, fields: Dictionary, file: String) -> Dictionary:
	var indexed := {}
	if values.is_empty():
		fail(file, "entries", "must not be empty")
	for index in values.size():
		var value = values[index]
		var id := str(value.get("id", "entry %d" % index)) if value is Dictionary else "entry %d" % index
		if not shape(value, fields, file, id):
			continue
		if indexed.has(id):
			fail(file, id, "duplicate ID")
		indexed[id] = value
	return indexed


func check_reference(id: String, known: Dictionary, file: String, owner: String, kind: String) -> void:
	if not known.has(id):
		fail(file, owner, "unknown %s '%s'" % [kind, id])


func scene_path(path: String, file: String, id: String) -> void:
	if not path.begins_with("res://") or ".." in path or not path.ends_with(".tscn"):
		fail(file, id, "scene must be a project-local res:// .tscn path")
	elif not ResourceLoader.exists(path, "PackedScene"):
		fail(file, id, "missing packed scene '%s'" % path)
	else:
		var packed = load(path)
		if not packed is PackedScene:
			fail(file, id, "resource is not a packed scene")
		elif not packed.get_state().get_node_type(0) == &"Node2D":
			fail(file, id, "visual scene root must be Node2D")


func point(value: Variant) -> bool:
	return value is Array and value.size() == 2 and is_number(value[0]) and is_number(value[1])


func is_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


func conditions(values: Array, flags: Dictionary, items: Dictionary, file: String, id: String) -> void:
	for condition in values:
		if not condition is Dictionary:
			fail(file, id, "condition must be an object")
		elif condition.has("flag"):
			if shape(condition, {"flag": TYPE_STRING, "value": TYPE_BOOL}, file, id):
				check_reference(condition.flag, flags, file, id, "flag")
		elif condition.has("item"):
			if shape(condition, {"item": TYPE_STRING, "owned": TYPE_BOOL}, file, id):
				check_reference(condition.item, items, file, id, "item")
		else:
			fail(file, id, "condition needs flag/value or item/owned")


func effects(values: Array, flags: Dictionary, items: Dictionary, nodes: Dictionary, file: String, id: String) -> void:
	for effect in values:
		if not effect is Dictionary or not effect.get("type") is String:
			fail(file, id, "effect requires a string type")
			continue
		match effect.type:
			"set_flag":
				if shape(effect, {"type": TYPE_STRING, "flag_id": TYPE_STRING, "value": TYPE_BOOL}, file, id):
					check_reference(effect.flag_id, flags, file, id, "flag")
			"grant_item", "consume_item":
				if shape(effect, {"type": TYPE_STRING, "item_id": TYPE_STRING}, file, id):
					check_reference(effect.item_id, items, file, id, "item")
			"show_text":
				shape(effect, {"type": TYPE_STRING, "text": TYPE_STRING}, file, id)
			"start_dialogue":
				if shape(effect, {"type": TYPE_STRING, "node_id": TYPE_STRING}, file, id):
					check_reference(effect.node_id, nodes, file, id, "dialogue node")
			"finish":
				shape(effect, {"type": TYPE_STRING}, file, id)
			_:
				fail(file, id, "unknown effect '%s'" % effect.type)


func validate(content: Dictionary) -> PackedStringArray:
	errors.clear()
	for file_id in FILES:
		if not content.get(file_id) is Dictionary:
			fail(file_id + ".json", "root", "missing content object")
	if not errors.is_empty():
		return errors
	var room: Dictionary = content.room
	var dialogue: Dictionary = content.dialogue
	var puzzle: Dictionary = content.puzzle
	shape(room, {"id": TYPE_STRING, "background_scene": TYPE_STRING, "hotspots": TYPE_ARRAY}, "room.json", "root")
	shape(content.items, {"items": TYPE_ARRAY}, "items.json", "root")
	shape(dialogue, {"initial_node_id": TYPE_STRING, "speakers": TYPE_ARRAY, "nodes": TYPE_ARRAY}, "dialogue.json", "root")
	shape(puzzle, {"initial_flags": TYPE_DICTIONARY, "failure_responses": TYPE_DICTIONARY, "rules": TYPE_ARRAY}, "puzzle.json", "root")
	if not errors.is_empty():
		return errors
	var hotspots := entries(room.hotspots, {"id": TYPE_STRING, "name": TYPE_STRING, "position": TYPE_ARRAY, "polygon": TYPE_ARRAY, "visual_scene": TYPE_STRING}, "room.json")
	var items := entries(content.items.items, {"id": TYPE_STRING, "name": TYPE_STRING, "description": TYPE_STRING, "icon_scene": TYPE_STRING}, "items.json")
	var speakers := entries(dialogue.speakers, {"id": TYPE_STRING, "name": TYPE_STRING}, "dialogue.json")
	var nodes := entries(dialogue.nodes, {"id": TYPE_STRING, "speaker_id": TYPE_STRING, "text": TYPE_STRING, "choices": TYPE_ARRAY}, "dialogue.json")
	var rules := entries(puzzle.rules, {"id": TYPE_STRING, "verb": TYPE_STRING, "target_id": TYPE_STRING, "item_id": TYPE_STRING, "requires": TYPE_ARRAY, "effects": TYPE_ARRAY, "failure_text": TYPE_STRING}, "puzzle.json")
	if not errors.is_empty():
		return errors
	var flags: Dictionary = puzzle.initial_flags
	if flags.is_empty():
		fail("puzzle.json", "initial_flags", "must not be empty")
	for id in flags:
		if id.is_empty() or not flags[id] is bool:
			fail("puzzle.json", str(id), "initial flag must have a nonempty ID and boolean value")
	shape(puzzle.failure_responses, {"look": TYPE_STRING, "use": TYPE_STRING, "talk": TYPE_STRING, "capacity": TYPE_STRING}, "puzzle.json", "failure_responses")
	scene_path(room.background_scene, "room.json", room.id)
	for id in hotspots:
		var hotspot: Dictionary = hotspots[id]
		scene_path(hotspot.visual_scene, "room.json", id)
		if not point(hotspot.position):
			fail("room.json", id, "position must be two finite numbers")
		var polygon := PackedVector2Array()
		for vertex in hotspot.polygon:
			if not point(vertex):
				fail("room.json", id, "polygon vertices must be pairs of finite numbers")
			else:
				polygon.append(Vector2(vertex[0], vertex[1]))
		var twice_area := 0.0
		for index in polygon.size():
			twice_area += polygon[index].cross(polygon[(index + 1) % polygon.size()])
		if polygon.size() < 3 or is_zero_approx(twice_area) or Geometry2D.triangulate_polygon(polygon).is_empty():
			fail("room.json", id, "polygon must enclose a nondegenerate area")
	for id in items:
		scene_path(items[id].icon_scene, "items.json", id)
	check_reference(dialogue.initial_node_id, nodes, "dialogue.json", "initial_node_id", "dialogue node")
	for id in nodes:
		var node: Dictionary = nodes[id]
		check_reference(node.speaker_id, speakers, "dialogue.json", id, "speaker")
		if node.choices.is_empty():
			fail("dialogue.json", id, "node must offer an explicit choice")
		for choice in node.choices:
			if not shape(choice, {"text": TYPE_STRING, "requires": TYPE_ARRAY, "effects": TYPE_ARRAY, "next_id": TYPE_STRING}, "dialogue.json", id, ["next_id"]):
				continue
			conditions(choice.requires, flags, items, "dialogue.json", id)
			effects(choice.effects, flags, items, nodes, "dialogue.json", id)
			if choice.has("next_id"):
				check_reference(choice.next_id, nodes, "dialogue.json", id, "dialogue node")
	for id in rules:
		var rule: Dictionary = rules[id]
		if rule.verb not in VERBS:
			fail("puzzle.json", id, "unknown verb '%s'" % rule.verb)
		check_reference(rule.target_id, hotspots, "puzzle.json", id, "hotspot")
		if not rule.item_id.is_empty():
			check_reference(rule.item_id, items, "puzzle.json", id, "item")
		conditions(rule.requires, flags, items, "puzzle.json", id)
		effects(rule.effects, flags, items, nodes, "puzzle.json", id)
	return errors
