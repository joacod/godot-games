extends RefCounted

var messages: Array[String] = []


func click(tree: SceneTree, point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	tree.root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		tree.root.push_input(event, true)
	await tree.process_frame



func run(tree: SceneTree, main: Node, check: Callable) -> void:
	var interaction: Node = main.get_node("Interaction")
	var ui: Control = main.get_node("UI/Presentation/InteractionUI")
	var regions: Node2D = main.get_node("Room/Hotspots")
	interaction.feedback_changed.connect(func(text: String): messages.append(text))
	var unchanged: Dictionary = main.content.duplicate(true)
	for region in regions.get_children():
		var polygon: PackedVector2Array = region.get_node("CollisionPolygon2D").polygon
		var center: Vector2 = region.position + (polygon[0] + polygon[2]) / 2.0
		check.call(interaction.target_at(center) == region.hotspot_id, "Discoverable center: " + region.hotspot_id)
		check.call(interaction.target_at(region.position + Vector2(3, 3)) == region.hotspot_id, "Generous edge hit: " + region.hotspot_id)
		interaction.select_verb("look")
		interaction.dispatch(region.hotspot_id)
		check.call(not messages.is_empty() and messages.back() == authored_look(main.content, region.hotspot_id), "Authored Look: " + region.hotspot_id)
		check.call(ui.get_node("Description/Text").text == messages.back(), "Look rendered: " + region.hotspot_id)
		for verb in ["use", "talk"]:
			interaction.select_verb(verb)
			var before := messages.size()
			interaction.dispatch(region.hotspot_id)
			check.call(messages.size() == before + 1 and not messages.back().is_empty(), "Use/Talk feedback: " + region.hotspot_id)
	check.call(main.content == unchanged, "All verbs leave content, flags and reward definitions unchanged")
	check.call(regions.get_child_count() == 5 and main.get_node("Room/Props/oil").visible, "Use does not collect oil or hide props")
	interaction.select_verb("use")
	interaction.dispatch("noticeboard")
	check.call(messages.back() == main.content.puzzle.failure_responses.use, "Unsupported Use uses authored fallback")
	interaction.select_verb("talk")
	interaction.dispatch("gate")
	check.call(messages.back() == main.content.puzzle.failure_responses.talk, "Unsupported Talk uses authored fallback")
	var before := messages.size()
	interaction.dispatch("unknown")
	interaction.dispatch("")
	check.call(messages.size() == before, "Unknown/empty targets do not dispatch")
	interaction.select_verb("invalid")
	check.call(interaction.selected_verb == "talk", "Unknown verb rejected")
	check.call(interaction.target_at(Vector2(450, 70)).is_empty(), "Empty room is not a target")

	# Overlap deliberately: authored order wins regardless of physics picking.
	var press: Node2D = regions.get_node("press")
	var old_position := press.position
	press.position = regions.get_node("oil").position
	check.call(interaction.target_at(press.position + Vector2(20, 20)) == "oil", "Overlapping hotspot has deterministic first-definition priority")
	press.position = old_position

	# Exercise actual viewport event routing, including a UI overlay over oil.
	var oil: Node2D = regions.get_node("oil")
	var oil_point: Vector2 = oil.get_global_transform_with_canvas() * Vector2(20, 20)
	var motion := InputEventMouseMotion.new()
	motion.position = oil_point
	tree.root.push_input(motion, true)
	await tree.process_frame
	await tree.process_frame
	check.call(ui.get_node("Hover").text == "Oil flask", "Mouse motion renders authored hover name")
	interaction.select_verb("look")
	before = messages.size()
	await click(tree, oil_point)
	check.call(messages.size() == before + 1 and messages.back() == main.content.puzzle.rules[0].effects[0].text, "Room mouse click dispatches once")
	var talk_button: Button = ui.get_node("Verbs/Talk")
	before = messages.size()
	await click(tree, talk_button.get_global_transform_with_canvas() * (talk_button.size / 2.0))
	check.call(interaction.selected_verb == "talk" and talk_button.button_pressed, "Native GUI input selects visible Talk verb")
	check.call(messages.size() == before, "Verb click does not dispatch scenery")

	var overlay := Button.new()
	overlay.position = oil.position
	overlay.size = Vector2(56, 75)
	main.get_node("UI/Presentation").add_child(overlay)
	await tree.process_frame
	before = messages.size()
	await click(tree, oil_point)
	check.call(messages.size() == before, "Overlay consumes click above hotspot")
	check.call(ui.get_node("Hover").text.is_empty(), "Hover clears over blocking UI")
	overlay.queue_free()
	await tree.process_frame
	interaction.modal_open = true
	before = messages.size()
	interaction.dispatch("oil")
	await click(tree, oil_point)
	check.call(messages.size() == before and interaction.target_at(oil.position + Vector2(20, 20)).is_empty(), "Modal blocks direct and mouse room dispatch")
	check.call(ui.get_node("Hover").text.is_empty(), "Modal clears hover")
	interaction.modal_open = false
	interaction.select_verb("look")
	await click(tree, oil_point)
	check.call(messages.size() == before + 1, "Room interaction resumes after modal closes")

	# Data replacement changes the visible response without touching scripts.
	var original_text: String = main.content.puzzle.rules[0].effects[0].text
	main.content.puzzle.rules[0].effects[0].text = "Replacement fixture description."
	interaction.dispatch("oil")
	check.call(ui.get_node("Description/Text").text == "Replacement fixture description.", "Edited content text is rendered")
	main.content.puzzle.rules[0].effects[0].text = original_text
	interaction.dispatch("press")
	check.call(ui.get_node("Verbs/Look").button_pressed and not ui.get_node("Verbs/Use").button_pressed and not ui.get_node("Verbs/Talk").button_pressed, "Only the selected verb remains pressed")

	# Never execute the text portion of a transaction or a conditional rule.
	var effects: Array = main.content.puzzle.rules[0].effects.duplicate(true)
	main.content.puzzle.rules[0].effects.append({"type": "set_flag", "flag_id": "oil_taken", "value": true})
	interaction.dispatch("oil")
	check.call(messages.back() == main.content.puzzle.failure_responses.look and not main.content.puzzle.initial_flags.oil_taken, "Mixed effects are skipped entirely")
	main.content.puzzle.rules[0].effects = effects
	main.content.puzzle.rules[0].requires = [{"flag": "oil_taken", "value": false}]
	interaction.dispatch("oil")
	check.call(messages.back() == main.content.puzzle.failure_responses.look, "Conditional rules remain deferred")
	main.content.puzzle.rules[0].requires = []
	interaction.dispatch("press")


func authored_look(content: Dictionary, target_id: String) -> String:
	for rule in content.puzzle.rules:
		if rule.verb == "look" and rule.target_id == target_id:
			return rule.effects[0].text
	return ""
