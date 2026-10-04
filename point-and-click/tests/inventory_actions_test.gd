extends RefCounted

const MainScene := preload("res://scenes/main.tscn")
const InputChecks := preload("res://tests/interaction_test.gd")
var messages: Array[String] = []


func run(tree: SceneTree, check: Callable, capture: Callable) -> void:
	var main := MainScene.instantiate()
	tree.root.add_child(main)
	await tree.process_frame
	var inventory: Node = main.get_node("Inventory")
	var state: Node = main.get_node("PuzzleState")
	var interaction: Node = main.get_node("Interaction")
	var bar: Control = main.get_node("UI/Presentation/InventoryBar")
	var ui: Control = main.get_node("UI/Presentation/InteractionUI")
	interaction.feedback_changed.connect(func(text: String): messages.append(text))
	var content_before: Dictionary = main.content.duplicate(true)
	check.call(bar.get_child_count() == 6 and inventory.items.is_empty(), "Six empty inventory slots")
	# Unique local test items fill capacity; shipped content only needs two IDs.
	var full: Array[String] = []
	for index in range(6):
		var id := "fixture_" + str(index)
		inventory.definitions[id] = {"name": "Fixture", "description": "Capacity fixture"}
		full.append(id)
	check.call(inventory.replace_items(full), "Six unique fixture items fit")
	inventory.changed.emit()
	interaction.select_verb("use")
	interaction.dispatch("oil")
	check.call(messages.back() == main.content.puzzle.failure_responses.capacity, "Full pickup reports authored capacity feedback")
	check.call(inventory.items == full and not state.flags.oil_taken, "Full pickup preserves inventory and flags")
	check.call(main.get_node("Room/Props/oil").visible and interaction.target_at(main.get_node("Room/Hotspots/oil").position + Vector2(20, 20)) == "oil", "Full pickup remains visible and targetable")
	var too_many: Array[String] = full.duplicate()
	too_many.append("oil")
	check.call(not inventory.replace_items(too_many) and inventory.items.size() == 6, "Inventory cannot exceed six")
	var duplicates: Array[String] = ["oil", "oil"]
	check.call(not inventory.replace_items(duplicates), "Duplicate unique items rejected")
	var unknown: Array[String] = ["unknown"]
	check.call(not inventory.replace_items(unknown), "Unknown item rejected")
	var empty: Array[String] = []
	inventory.replace_items(empty)
	inventory.changed.emit()
	var inputs := InputChecks.new()
	var oil: Node2D = main.get_node("Room/Hotspots/oil")
	var oil_point: Vector2 = oil.get_global_transform_with_canvas() * Vector2(20, 20)
	await inputs.click(tree, oil_point)
	check.call(inventory.items == ["oil"] and state.flags.oil_taken, "Mouse pickup commits oil and flag")
	check.call(not main.get_node("Room/Props/oil").visible and not oil.visible and not main.get_node("Room/oilLabel").visible, "Pickup hides visual, region and label")
	check.call(interaction.target_at(oil.position + Vector2(20, 20)).is_empty(), "Hidden pickup has no hover/click hit")
	interaction.dispatch("oil")
	check.call(inventory.items == ["oil"] and messages.back() == main.content.puzzle.rules[5].failure_text, "Repeated pickup cannot duplicate")
	await inputs.click(tree, bar.get_child(0).get_global_transform_with_canvas() * (bar.get_child(0).size / 2.0))
	check.call(interaction.selected_item == "oil" and interaction.selected_verb == "use", "GUI slot selects item and Use")
	check.call("Oil flask" in ui.get_node("ItemPrompt").text and bar.get_child(0).button_pressed, "Selected item prompt and slot shown")
	await capture.call("inventory-selected")
	var before := messages.size()
	var cancel := InputEventMouseButton.new()
	cancel.button_index = MOUSE_BUTTON_RIGHT
	cancel.position = Vector2(260, 196)
	cancel.pressed = true
	tree.root.push_input(cancel, true)
	cancel = cancel.duplicate()
	cancel.pressed = false
	tree.root.push_input(cancel, true)
	await tree.process_frame
	check.call(interaction.selected_item.is_empty() and inventory.items == ["oil"] and messages.size() == before, "Right-click cancels without use or discard")
	check.call(ui.get_node("ItemPrompt").text.is_empty() and not bar.get_child(0).button_pressed, "Cancel clears item presentation")
	interaction.dispatch("press")
	check.call(messages.back() == main.content.puzzle.rules[12].effects[0].text and not state.flags.press_repaired, "Cancel restores normal Use clue")
	interaction.select_item("unknown")
	check.call(interaction.selected_item.is_empty(), "Unowned selection rejected")
	interaction.select_item("oil")
	interaction.dispatch("clerk")
	check.call(inventory.items == ["oil"] and not state.flags.press_repaired and messages.back() == main.content.puzzle.rules[13].effects[0].text, "Oil on clerk retains oil and uses authored response")
	interaction.dispatch("noticeboard")
	check.call(inventory.items == ["oil"] and not state.flags.press_repaired, "Unsupported combination preserves progress")
	interaction.select_verb("look")
	check.call(interaction.selected_item.is_empty(), "Explicit verb clears item selection")
	interaction.select_item("oil")
	interaction.modal_open = true
	interaction.dispatch("press")
	interaction.select_item("pass")
	check.call(not state.flags.press_repaired and inventory.items == ["oil"], "Modal blocks item actions")
	interaction.modal_open = false
	# Put an interactive inventory control above the press to prove no click-through.
	var press: Node2D = main.get_node("Room/Hotspots/press")
	var old_position := press.position
	press.position = Vector2(20, 284)
	before = messages.size()
	await inputs.click(tree, bar.get_child(0).get_global_transform_with_canvas() * (bar.get_child(0).size / 2.0))
	check.call(messages.size() == before and not state.flags.press_repaired, "Inventory click cannot activate underlying press")
	press.position = old_position
	# Late failure must roll back earlier flags/consumption/text without signals.
	var bad := {"requires": [], "failure_text": "Fixture failure", "effects": [
		{"type": "set_flag", "flag_id": "press_repaired", "value": true},
		{"type": "consume_item", "item_id": "oil"},
		{"type": "show_text", "text": "Must not appear"},
		{"type": "consume_item", "item_id": "pass"}]}
	var observations: Array[bool] = []
	state.changed.connect(func(): observations.append(state.flags.press_repaired and inventory.items.is_empty()))
	check.call(not state.apply(bad).ok and inventory.items == ["oil"] and not state.flags.press_repaired and observations.is_empty(), "Late failed effect rolls back entire action with no signals")
	var duplicate := {"requires": [], "failure_text": "Duplicate", "effects": [{"type": "grant_item", "item_id": "oil"}, {"type": "set_flag", "flag_id": "pass_granted", "value": true}]}
	check.call(not state.apply(duplicate).ok and not state.flags.pass_granted and inventory.items == ["oil"], "Duplicate grant cannot commit reward flag")
	var deferred := {"requires": [], "failure_text": "Deferred", "effects": [{"type": "consume_item", "item_id": "oil"}, {"type": "finish"}]}
	check.call(not state.apply(deferred).ok and inventory.items == ["oil"], "Deferred completion cannot partially consume")
	await inputs.click(tree, press.get_global_transform_with_canvas() * Vector2(30, 30))
	check.call(state.flags.press_repaired and inventory.items.is_empty() and interaction.selected_item.is_empty(), "Mouse repair consumes once and clears selection")
	check.call(observations == [true], "State observers see complete transaction exactly once")
	check.call(main.get_node("Room/Props/press/Shape4").position.y == -10 and "repaired" in main.get_node("Room/pressLabel").text, "Repair changes shape and readable label")
	interaction.dispatch("press")
	check.call("repaired" in messages.back() and inventory.items.is_empty(), "Repeated bare Use gives repaired feedback")
	check.call(not state.apply(main.content.puzzle.rules[6]).ok and observations == [true], "Repeated repair rejected without further state change")
	interaction.select_verb("talk")
	interaction.dispatch("clerk")
	check.call(not state.flags.pass_granted and not state.flags.complete and inventory.items.is_empty(), "Dialogue and completion remain deferred")
	check.call(main.content == content_before, "Actions never mutate content definitions")
	await capture.call("press-repaired")
	main.queue_free()
	await tree.process_frame
