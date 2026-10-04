extends RefCounted

const MainScene := preload("res://scenes/main.tscn")
const InputChecks := preload("res://tests/interaction_test.gd")


func run(tree: SceneTree, check: Callable, capture: Callable) -> void:
	var main := MainScene.instantiate()
	tree.root.add_child(main)
	await tree.process_frame
	var state: Node = main.get_node("PuzzleState")
	var inventory: Node = main.get_node("Inventory")
	var interaction: Node = main.get_node("Interaction")
	var dialogue: Node = main.get_node("Dialogue")
	var panel: Control = main.get_node("UI/Presentation/DialoguePanel")
	var list: VBoxContainer = panel.get_node("Panel/Margin/Rows/Scroll/Content/Choices")
	var inputs := InputChecks.new()
	var completions: Array[bool] = []
	var starts: Array[String] = []
	state.finished.connect(func(): completions.append(state.flags.complete and state.completed and "pass" in inventory.items))
	state.dialogue_requested.connect(func(id: String): starts.append(id))
	var original: Dictionary = main.content.duplicate(true)
	interaction.select_verb("use")
	interaction.dispatch("gate")
	check.call(not state.flags.complete and inventory.items.is_empty(), "Early gate leaves route available")
	interaction.select_verb("talk")
	interaction.dispatch("clerk")
	check.call(dialogue.current_node_id == "jammed" and panel.visible and interaction.modal_open, "Early Talk opens modal clue")
	check.call(panel.get_node("Panel/Margin/Rows/Speaker").text == "Gate clerk", "JSON speaker displayed")
	check.call(panel.get_node("Panel/Margin/Rows/Scroll/Content/Line").text == original.dialogue.nodes[0].text, "JSON line displayed")
	check.call(list.get_child_count() == 1 and list.get_child(0).text == original.dialogue.nodes[0].choices[0].text, "JSON choice displayed")
	await capture.call("dialogue-jammed")
	interaction.select_verb("use")
	interaction.dispatch("oil")
	check.call(interaction.selected_verb == "talk" and not state.flags.oil_taken, "Modal rejects verbs and dispatch")
	var oil: Node2D = main.get_node("Room/Hotspots/oil")
	await inputs.click(tree, oil.get_global_transform_with_canvas() * Vector2(20, 20))
	check.call(not state.flags.oil_taken and dialogue.current_node_id == "jammed", "Modal backdrop consumes room click")
	# Move oil beneath a choice: accepting the clue cannot pick it up.
	var old_position := oil.position
	var button: Button = list.get_child(0)
	await tree.process_frame
	var choice_point: Vector2 = button.get_global_transform_with_canvas() * (button.size / 2)
	oil.position = choice_point - Vector2(20, 20)
	await inputs.click(tree, choice_point)
	check.call(dialogue.current_node_id.is_empty() and not panel.visible and not interaction.modal_open, "Explicit choice closes dialogue")
	check.call(not state.flags.oil_taken, "Choice click cannot activate underlying pickup")
	oil.position = old_position
	interaction.dispatch("clerk")
	for key in [MOUSE_BUTTON_RIGHT, KEY_ESCAPE]:
		var event: InputEvent
		if key == MOUSE_BUTTON_RIGHT:
			event = InputEventMouseButton.new()
			event.button_index = key
		else:
			event = InputEventKey.new()
			event.physical_keycode = key
		event.pressed = true
		tree.root.push_input(event, true)
		event = event.duplicate()
		event.pressed = false
		tree.root.push_input(event, true)
		await tree.process_frame
		check.call(not interaction.modal_open and not state.flags.pass_granted, "Cancel exits without reward: " + str(key))
		interaction.dispatch("clerk")
	await inputs.click(tree, panel.get_node("Panel/Margin/Rows/Cancel").get_global_transform_with_canvas() * (panel.get_node("Panel/Margin/Rows/Cancel").size / 2))
	check.call(not interaction.modal_open, "Visible cancel button closes dialogue")
	interaction.select_verb("use")
	interaction.dispatch("oil")
	interaction.select_item("oil")
	interaction.dispatch("gate")
	check.call(inventory.items == ["oil"] and not state.flags.complete, "Wrong item on gate preserves oil")
	interaction.dispatch("clerk")
	check.call(inventory.items == ["oil"] and not state.flags.pass_granted, "Oil on clerk preserves progress")
	interaction.dispatch("press")
	check.call(state.flags.press_repaired and inventory.items.is_empty(), "Repair consumes oil")
	interaction.select_verb("talk")
	interaction.dispatch("clerk")
	check.call(dialogue.current_node_id == "repaired" and dialogue.choices.size() == 2, "Repair selects request dialogue")
	await capture.call("dialogue-repaired")
	# A failed reward must leave the conversation available for retry.
	var full: Array[String] = []
	for index in 6:
		var id := "capacity_" + str(index)
		inventory.definitions[id] = {"name": "Fixture", "description": "Capacity"}
		full.append(id)
	inventory.replace_items(full)
	inventory.publish_changed()
	dialogue.choose(0)
	check.call(inventory.items == full and not state.flags.pass_granted, "Capacity failure leaves item and flag uncommitted")
	check.call(dialogue.current_node_id == "repaired" and dialogue.choices.size() == 2, "Capacity failure preserves retry choice")
	check.call(panel.get_node("Panel/Margin/Rows/Feedback").text == original.puzzle.failure_responses.capacity, "Capacity feedback visible inside modal")
	await capture.call("dialogue-capacity")
	var empty: Array[String] = []
	inventory.replace_items(empty)
	inventory.publish_changed()
	await tree.process_frame
	button = list.get_child(0)
	await inputs.click(tree, button.get_global_transform_with_canvas() * (button.size / 2))
	check.call(inventory.items == ["pass"] and state.flags.pass_granted, "GUI request grants one pass after retry")
	check.call(dialogue.current_node_id == "issued" and interaction.modal_open, "Successful request follows next node")
	await capture.call("dialogue-issued")
	dialogue.choose(0)
	check.call(not interaction.modal_open, "Thank-you ends conversation")
	interaction.dispatch("clerk")
	check.call(dialogue.current_node_id == "issued" and inventory.items == ["pass"], "Repeated Talk chooses issued dialogue without duplicate")
	dialogue.close()
	# Choice conditions are rechecked at commit, including stale rendered choices.
	dialogue.open("repaired")
	check.call(dialogue.choices.size() == 1 and dialogue.choices[0].text == "Not yet.", "Reward choice filtered after grant")
	dialogue.close()
	state.flags.pass_granted = false
	dialogue.open("repaired")
	state.flags.pass_granted = true
	dialogue.choose(0)
	check.call(inventory.items == ["pass"] and dialogue.current_node_id == "repaired" and dialogue.choices.size() == 1, "Stale choice cannot duplicate reward")
	dialogue.close()
	# All three text fields can be reskinned without mechanics changes.
	dialogue.speakers.clerk = "Fixture clerk"
	dialogue.nodes.jammed.text = "Fixture oil clue"
	dialogue.nodes.jammed.choices[0].text = "Fixture choice"
	dialogue.open("jammed")
	check.call(panel.get_node("Panel/Margin/Rows/Speaker").text == "Fixture clerk" and panel.get_node("Panel/Margin/Rows/Scroll/Content/Line").text == "Fixture oil clue" and list.get_child(0).text == "Fixture choice", "Replacement JSON text renders in speaker, line and choice")
	dialogue.speakers.clerk = "Gate clerk"
	dialogue.nodes.jammed.text = original.dialogue.nodes[0].text
	dialogue.nodes.jammed.choices[0].text = original.dialogue.nodes[0].choices[0].text
	dialogue.close()
	# Side effects cannot escape a failed transaction.
	var failed := {"requires": [], "failure_text": "Fixture failure", "effects": [{"type": "start_dialogue", "node_id": "jammed"}, {"type": "finish"}, {"type": "consume_item", "item_id": "oil"}]}
	var before := starts.size()
	check.call(not state.apply(failed).ok and starts.size() == before and completions.is_empty() and not state.completed, "Late failure emits no dialogue or completion")
	interaction.select_item("pass")
	var gate: Node2D = main.get_node("Room/Hotspots/gate")
	await inputs.click(tree, gate.get_global_transform_with_canvas() * Vector2(20, 20))
	check.call(state.flags.complete and state.completed and completions == [true], "Pass on gate emits completion after committed state")
	check.call("opens the gate" in main.get_node("UI/Presentation/InteractionUI/Description/Text").text, "Completion feedback is authored data")
	interaction.dispatch("gate")
	check.call(completions == [true] and inventory.items == ["pass"], "Repeated gate cannot complete twice or lose pass")
	state.apply({"requires": [], "effects": [{"type": "finish"}], "failure_text": "Fixture"})
	check.call(completions == [true], "Finish effect itself emits once")
	check.call(main.content == original, "Full puzzle chain preserves loaded content")
	await capture.call("puzzle-complete")
	main.queue_free()
	await tree.process_frame
