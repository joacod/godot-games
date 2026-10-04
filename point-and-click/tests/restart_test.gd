extends RefCounted

const MainScene := preload("res://scenes/main.tscn")
const InputChecks := preload("res://tests/interaction_test.gd")


func key(tree: SceneTree, code: int) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.pressed = pressed
		tree.root.push_input(event, true)
	await tree.process_frame


func click_button(tree: SceneTree, inputs: RefCounted, button: Button) -> void:
	await tree.process_frame
	await inputs.click(tree, button.get_global_transform_with_canvas() * (button.size / 2))


func finish(main: Node) -> void:
	var interaction: Node = main.get_node("Interaction")
	interaction.select_verb("use")
	interaction.dispatch("oil")
	interaction.select_item("oil")
	interaction.dispatch("press")
	interaction.select_verb("talk")
	interaction.dispatch("clerk")
	main.get_node("Dialogue").choose(0)
	main.get_node("Dialogue").choose(0)
	interaction.select_item("pass")
	interaction.dispatch("gate")


func fresh(main: Node, check: Callable) -> void:
	check.call(main.lifecycle == "playing" and not main.get_node("Interaction").modal_open, "Restart resumes a playable fresh room")
	check.call(main.get_node("PuzzleState").flags == main.content.puzzle.initial_flags and not main.get_node("PuzzleState").completed, "Restart resets all flags and completion latch")
	check.call(main.get_node("Inventory").items.is_empty() and main.get_node("Inventory").definitions.size() == 2, "Restart removes items and any runtime definitions")
	check.call(main.get_node("Interaction").selected_item.is_empty() and main.get_node("Interaction").selected_verb == "look", "Restart clears selection and resets verb")
	check.call(main.get_node("Dialogue").current_node_id.is_empty() and main.get_node("Dialogue").choices.is_empty() and main.get_node("Dialogue").feedback.is_empty(), "Restart clears dialogue cursor, choices and feedback")
	check.call(not main.get_node("UI/Presentation/DialoguePanel").visible and main.get_node("UI/Presentation/Menus").screen.is_empty(), "Restart removes stale modal presentation")
	check.call(main.get_node("Room/Props/oil").visible and main.get_node("Room/Hotspots/oil").visible and main.get_node("Room/oilLabel").visible, "Restart restores oil visual, label and hit region")
	check.call(is_equal_approx(main.get_node("Room/Props/press/Shape4").position.y, 0) and main.get_node("Room/pressLabel").text == "Stamp press", "Restart restores original press shape and label")
	check.call(main.get_node("Room/Props/gate/Shape5").visible and main.get_node("Room/gateLabel").text == "Exit gate", "Restart closes gate shape and label")
	check.call(main.get_node("UI/Presentation/InteractionUI/Description/Text").text == main.get_node("UI/Presentation").theme.get_meta("interaction_hint"), "Restart resets previous feedback")
	check.call(main.get_node("Room/Camera2D").position == Vector2(320, 180), "Lifecycle preserves fixed camera")


func run(tree: SceneTree, check: Callable, capture: Callable) -> void:
	var main := MainScene.instantiate()
	tree.root.add_child(main)
	await tree.process_frame
	var inputs := InputChecks.new()
	var menus: Control = main.get_node("UI/Presentation/Menus")
	check.call(main.lifecycle == "start" and main.get_node("Interaction").modal_open, "Startup blocks gameplay until Start")
	main.get_node("Interaction").select_verb("use")
	main.get_node("Interaction").dispatch("oil")
	await inputs.click(tree, main.get_node("Room/Hotspots/oil").get_global_transform_with_canvas() * Vector2(20, 20))
	check.call(not main.get_node("PuzzleState").flags.oil_taken, "Start overlay blocks direct and injected room clicks")
	await capture.call("menu-start")
	await click_button(tree, inputs, menus.get_node("Panel/Margin/Rows/Primary"))
	fresh(main, check)
	await key(tree, KEY_ESCAPE)
	check.call(main.lifecycle == "pause", "Escape pauses idle gameplay")
	await capture.call("menu-pause")
	await key(tree, KEY_ESCAPE)
	check.call(main.lifecycle == "playing", "Escape resumes pause without reopening it")
	main.get_node("Interaction").select_verb("use")
	main.get_node("Interaction").dispatch("oil")
	main.get_node("Interaction").select_item("oil")
	await key(tree, KEY_ESCAPE)
	check.call(main.lifecycle == "playing" and main.get_node("Interaction").selected_item.is_empty(), "Escape cancels selected item before pausing")
	main.get_node("Interaction").select_verb("talk")
	main.get_node("Interaction").dispatch("clerk")
	await click_button(tree, inputs, menus.get_node("Pause"))
	check.call(main.lifecycle == "pause" and main.get_node("Dialogue").current_node_id == "jammed" and not main.get_node("UI/Presentation/DialoguePanel").visible, "Pause suspends an open conversation without clearing it")
	main.get_node("Interaction").dispatch("press")
	await click_button(tree, inputs, menus.get_node("Panel/Margin/Rows/Primary"))
	check.call(main.lifecycle == "playing" and main.get_node("UI/Presentation/DialoguePanel").visible and main.get_node("Interaction").modal_open, "Resume restores dialogue with room still locked")
	await key(tree, KEY_ESCAPE)
	check.call(main.lifecycle == "playing" and main.get_node("Dialogue").current_node_id.is_empty(), "Escape closes dialogue before pause")
	main = main.restart_game()
	await tree.process_frame
	for stage in ["initial", "mid-puzzle", "repaired", "dialogue-open", "complete"]:
		if stage == "mid-puzzle":
			main.get_node("Interaction").select_verb("use")
			main.get_node("Interaction").dispatch("oil")
			main.get_node("Interaction").select_item("oil")
		elif stage in ["repaired", "dialogue-open"]:
			main.get_node("Interaction").select_verb("use")
			main.get_node("Interaction").dispatch("oil")
			main.get_node("Interaction").select_item("oil")
			main.get_node("Interaction").dispatch("press")
			if stage == "dialogue-open":
				main.get_node("Interaction").select_verb("talk")
				main.get_node("Interaction").dispatch("clerk")
		elif stage == "complete":
			finish(main)
			check.call(main.lifecycle == "complete" and main.get_node("Interaction").modal_open, "Finish opens terminal screen and locks room")
			check.call(not main.get_node("Room/Props/gate/Shape5").visible and main.get_node("Room/gateLabel").text == "Exit gate (open)", "Completion opens gate shape and label")
			for index in 20:
				main.get_node("Interaction").dispatch("gate")
				main.pause_game()
			check.call(main.lifecycle == "complete" and main.get_node("Inventory").items == ["pass"], "Rapid repeat input cannot leave completion or lose pass")
			await capture.call("menu-complete")
		if stage != "complete":
			main.pause_game()
		var old := main
		menus = main.get_node("UI/Presentation/Menus")
		await click_button(tree, inputs, menus.get_node("Panel/Margin/Rows/Restart"))
		check.call(not is_instance_valid(old) or not old.is_inside_tree(), "GUI restart removes previous run: " + stage)
		main = tree.root.get_child(tree.root.get_child_count() - 1)
		fresh(main, check)
		finish(main)
		check.call(main.lifecycle == "complete", "Rebuilt puzzle finishes after restart: " + stage)
		main = main.restart_game()
		await tree.process_frame
	# Text stress fixtures stay local to this run, never alter shipped resources.
	var long_text := "A long authored sentence that must remain readable through scrolling. ".repeat(30)
	var description: RichTextLabel = main.get_node("UI/Presentation/InteractionUI/Description/Text")
	main.get_node("Interaction").feedback_changed.emit(long_text)
	main.get_node("Inventory").definitions.oil.name = "A very long oil flask inventory display name"
	main.get_node("Interaction").select_verb("use")
	main.get_node("Interaction").dispatch("oil")
	main.get_node("Interaction").select_item("oil")
	main.get_node("Interaction").feedback_changed.emit(long_text)
	await tree.process_frame
	await tree.process_frame
	check.call(description.get_content_height() > description.size.y and description.scroll_active, "Long feedback stays in a scrollable description region")
	check.call(Rect2(Vector2.ZERO, Vector2(640, 360)).encloses(description.get_global_rect()), "Long feedback does not expand beyond viewport")
	for slot in main.get_node("UI/Presentation/InventoryBar").slots:
		check.call(slot.get_global_rect().end.x <= 620 and slot.clip_text, "Six inventory slots fit even with long item names")
	check.call("very long oil" in main.get_node("UI/Presentation/InventoryBar").slots[0].tooltip_text, "Tooltip preserves full inventory name")
	await capture.call("long-feedback")
	main.get_node("Interaction").cancel_selection()
	main.get_node("Dialogue").nodes.jammed.text = long_text
	main.get_node("Dialogue").nodes.jammed.choices[0].text = long_text
	main.get_node("Interaction").select_verb("talk")
	main.get_node("Interaction").dispatch("clerk")
	await tree.process_frame
	await tree.process_frame
	var panel: Control = main.get_node("UI/Presentation/DialoguePanel")
	var scroll: ScrollContainer = panel.get_node("Panel/Margin/Rows/Scroll")
	check.call(scroll.get_node("Content").size.y > scroll.size.y and scroll.get_global_rect().end.y < 360, "Long dialogue and choices scroll inside viewport")
	await capture.call("long-dialogue")
	scroll.scroll_vertical = int(scroll.get_node("Content").size.y)
	await tree.process_frame
	var choice: Button = panel.get_node("Panel/Margin/Rows/Scroll/Content/Choices").get_child(0)
	var visible_choice := choice.get_global_rect().intersection(scroll.get_global_rect())
	await inputs.click(tree, panel.get_global_transform_with_canvas() * visible_choice.get_center())
	check.call(main.get_node("Dialogue").current_node_id.is_empty(), "Long choice remains reachable and clickable by scrolling")
	main = main.restart_game()
	await tree.process_frame
	fresh(main, check)
	await capture.call("restart-fresh")
	main.queue_free()
	await tree.process_frame
