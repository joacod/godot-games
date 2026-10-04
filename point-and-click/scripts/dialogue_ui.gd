extends Control

var dialogue: Node


func configure(controller: Node) -> void:
	dialogue = controller
	dialogue.updated.connect(refresh)
	$Panel/Margin/Rows/Cancel.text = theme.get_meta("dialogue_cancel")
	$Panel/Margin/Rows/Cancel.pressed.connect(dialogue.close)
	refresh()


func refresh() -> void:
	visible = not dialogue.current_node_id.is_empty()
	var list: VBoxContainer = $Panel/Margin/Rows/Scroll/Content/Choices
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	if not visible:
		return
	$Panel/Margin/Rows/Feedback.text = dialogue.feedback
	$Panel/Margin/Rows/Feedback.visible = not dialogue.feedback.is_empty()
	var node: Dictionary = dialogue.nodes[dialogue.current_node_id]
	$Panel/Margin/Rows/Speaker.text = dialogue.speakers[node.speaker_id]
	$Panel/Margin/Rows/Scroll/Content/Line.text = node.text
	for index in dialogue.choices.size():
		var button := Button.new()
		button.text = dialogue.choices[index].text
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 32
		button.pressed.connect(dialogue.choose.bind(index))
		list.add_child(button)
	$Panel/Margin/Rows/Scroll.scroll_vertical = 0
