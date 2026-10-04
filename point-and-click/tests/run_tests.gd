extends SceneTree

const ContentLoader := preload("res://scripts/content_loader.gd")
const MainScene := preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var baseline: Dictionary
var capture_directory := ""


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func reject(change: Callable, file: String, fragment: String) -> void:
	var fixture := baseline.duplicate(true)
	change.call(fixture)
	var errors := ContentLoader.new().validate(fixture)
	check(not errors.is_empty(), "Invalid fixture accepted: " + fragment)
	check(file in "\n".join(errors) and fragment in "\n".join(errors), "Missing actionable error: " + str(errors))


func capture(name: String) -> void:
	if capture_directory.is_empty():
		return
	await process_frame
	RenderingServer.force_draw(false)
	var image := root.get_texture().get_image()
	check(image.save_png(capture_directory.path_join(name + ".png")) == OK, "Save native viewport capture")


func run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_directory = argument.trim_prefix("--capture-dir=")
			DirAccess.make_dir_recursive_absolute(capture_directory)
	var loaded := ContentLoader.new().load_content()
	check(loaded.errors.is_empty(), "Default content: " + str(loaded.errors))
	baseline = loaded.content
	if baseline.is_empty():
		quit(1)
		return
	var parser := ContentLoader.new()
	parser.parse_document('{"id":', "fixture/room.json")
	check("fixture/room.json [JSON]: line" in "\n".join(parser.errors), "Malformed JSON must identify file and line")
	parser.errors.clear()
	parser.parse_document('[]', "fixture/items.json")
	check("expected object" in "\n".join(parser.errors), "Array root must fail")
	var missing := ContentLoader.new().load_content("res://missing-fixture")
	check(missing.content.is_empty() and missing.errors.size() == 4, "Missing files must prevent partial content")

	reject(func(c): c.room.hotspots.append(c.room.hotspots[0].duplicate(true)), "room.json", "oil")
	reject(func(c): c.items.items.append(c.items.items[0].duplicate(true)), "items.json", "oil")
	reject(func(c): c.dialogue.nodes.append(c.dialogue.nodes[0].duplicate(true)), "dialogue.json", "jammed")
	reject(func(c): c.dialogue.speakers.append(c.dialogue.speakers[0].duplicate(true)), "dialogue.json", "clerk")
	reject(func(c): c.puzzle.rules.append(c.puzzle.rules[0].duplicate(true)), "puzzle.json", "look_oil")
	reject(func(c): c.room.erase("hotspots"), "room.json", "hotspots")
	reject(func(c): c.room.hotspots = {}, "room.json", "hotspots")
	reject(func(c): c.items.items[0].name = 23, "items.json", "oil")
	reject(func(c): c.room.hotspots[0].id = "", "room.json", "must not be empty")
	reject(func(c): c.room.hotspots[0].position = [1, "bad"], "room.json", "oil")
	reject(func(c): c.room.hotspots[0].polygon = [[0, 0], [1, 1]], "room.json", "nondegenerate")
	reject(func(c): c.room.hotspots[0].polygon = [[0, 0], [1, 1], [2, 2]], "room.json", "nondegenerate")
	reject(func(c): c.room.hotspots[0].polygon = [[0, 0], [1, "x"], [2, 2]], "room.json", "vertices")
	reject(func(c): c.room.background_scene = "../other-game/room.tscn", "room.json", "project-local")
	reject(func(c): c.room.hotspots[0].visual_scene = "res://absent.tscn", "room.json", "oil")
	reject(func(c): c.items.items[0].icon_scene = "res://scenes/main.tscn", "items.json", "Node2D")
	reject(func(c): c.dialogue.initial_node_id = "absent", "dialogue.json", "initial_node_id")
	reject(func(c): c.dialogue.nodes[0].speaker_id = "absent", "dialogue.json", "jammed")
	reject(func(c): c.dialogue.nodes[1].choices[0].next_id = "absent", "dialogue.json", "repaired")
	reject(func(c): c.dialogue.nodes[0].choices = [], "dialogue.json", "explicit choice")
	reject(func(c): c.dialogue.nodes[0].choices[0].text = false, "dialogue.json", "jammed")
	reject(func(c): c.dialogue.nodes[0].choices[0].requires = [42], "dialogue.json", "condition")
	reject(func(c): c.dialogue.nodes[0].choices[0].requires = [{"script": "evil"}], "dialogue.json", "condition")
	reject(func(c): c.dialogue.nodes[0].choices[0].requires = [{"flag": "absent", "value": true}], "dialogue.json", "absent")
	reject(func(c): c.dialogue.nodes[0].choices[0].requires = [{"item": "absent", "owned": true}], "dialogue.json", "absent")
	reject(func(c): c.puzzle.initial_flags.oil_taken = 1, "puzzle.json", "boolean")
	reject(func(c): c.puzzle.failure_responses.use = "", "puzzle.json", "use")
	reject(func(c): c.puzzle.rules[0].verb = "fight", "puzzle.json", "look_oil")
	reject(func(c): c.puzzle.rules[0].target_id = "absent", "puzzle.json", "hotspot")
	reject(func(c): c.puzzle.rules[0].item_id = "absent", "puzzle.json", "item")
	reject(func(c): c.puzzle.rules[0].requires = [{"flag": "oil_taken", "value": 1}], "puzzle.json", "value")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "execute_script"}], "puzzle.json", "unknown effect")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "set_flag", "flag_id": "absent", "value": true}], "puzzle.json", "absent")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "grant_item", "item_id": "absent"}], "puzzle.json", "absent")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "consume_item", "item_id": "absent"}], "puzzle.json", "absent")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "start_dialogue", "node_id": "absent"}], "puzzle.json", "absent")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "show_text", "text": 5}], "puzzle.json", "text")
	reject(func(c): c.puzzle.rules[0].effects = [{"type": "finish", "script": "evil"}], "puzzle.json", "unknown field")
	reject(func(c): c.puzzle.rules[0].effects = ["finish"], "puzzle.json", "string type")
	reject(func(c): c.dialogue.nodes[0].choices[0].effects = [{"type": "bad"}], "dialogue.json", "jammed")

	# Validate error handling in the actual startup path, without mutating shipped data.
	var error_main := MainScene.instantiate()
	error_main.content_directory = "res://missing-fixture"
	root.add_child(error_main)
	await process_frame
	check(error_main.content.is_empty(), "Error startup exposes no partial content")
	check(not error_main.get_node("Room").visible, "Invalid content must hide room")
	check(error_main.get_node("Room/Props").get_child_count() == 0, "Invalid content must not build props")
	check(error_main.get_node("UI/Presentation/ErrorPanel").visible, "Invalid content must show visible errors")
	check("room.json" in error_main.get_node("UI/Presentation/ErrorPanel/Scroll/Errors").text, "Error panel must name failing file")
	await capture("content-error")
	error_main.queue_free()
	await process_frame
	var main := MainScene.instantiate()
	root.add_child(main)
	main.start_game()
	await process_frame
	check(main.content_errors.is_empty() and main.get_node("Room").visible, "Valid startup must reveal room")
	check(main.get_node("Room/Hotspots").get_child_count() == 5, "Five hotspot definitions instantiated")
	check(main.get_node("Room/Props").get_child_count() == 5, "Five independent prop visuals instantiated")
	check(main.get_node("Room/Camera2D").position == Vector2(320, 180), "Camera framing is fixed")
	for area in main.get_node("Room/Hotspots").get_children():
		check(not area.input_pickable, "Physics picking disabled for ordered central dispatch")
		check(area.get_meta("hotspot_id") == str(area.name), "Stable hotspot IDs retained")
		check(area.get_child(0).polygon.size() == 4, "Authored collision geometry retained")
		var rect := Rect2(area.position, area.get_child(0).polygon[2])
		check(Rect2(0, 60, 640, 240).encloses(rect), "Hotspot remains within stage and outside UI")
	var names: Array[String] = []
	var oil_label_rect: Rect2
	for child in main.get_node("Room").get_children():
		if child is Label:
			names.append(child.text)
			check(child.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Decorative label ignores clicks")
			if child.text == "Oil flask":
				oil_label_rect = child.get_rect()
	check(names.size() == 5 and "Noticeboard" in names and "Exit gate" in names, "Every prop has an authored label")
	check(main.get_node("UI/Presentation/InteractionUI").visible, "Validated startup reveals interaction UI")
	for action in ["interact", "cancel", "pause"]:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "Input configured: " + action)
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "Logical viewport width")
	check(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "Logical viewport height")
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility renderer retained")
	await preload("res://tests/interaction_test.gd").new().run(self, main, check)
	await capture("room")
	main.queue_free()
	await process_frame
	# The same polygon may start at any vertex without changing its label layout.
	var reordered := baseline.duplicate(true)
	var polygon: Array = reordered.room.hotspots[0].polygon
	reordered.room.hotspots[0].polygon = polygon.slice(2) + polygon.slice(0, 2)
	check(ContentLoader.new().validate(reordered).is_empty(), "Reordered polygon remains valid content")
	var reordered_main := MainScene.instantiate()
	reordered_main.content_directory = "res://missing-fixture"
	root.add_child(reordered_main)
	reordered_main.content = reordered
	reordered_main.build_room()
	await process_frame
	var reordered_label_rect: Rect2
	for child in reordered_main.get_node("Room").get_children():
		if child is Label and child.text == "Oil flask":
			reordered_label_rect = child.get_rect()
	check(reordered_label_rect == oil_label_rect, "Reordered polygon preserves label position and width")
	reordered_main.queue_free()
	await process_frame
	await preload("res://tests/inventory_actions_test.gd").new().run(self, check, capture)
	await preload("res://tests/puzzle_chain_test.gd").new().run(self, check, capture)
	await preload("res://tests/restart_test.gd").new().run(self, check, capture)
	print("Foundation + interaction + inventory + puzzle + lifecycle checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
