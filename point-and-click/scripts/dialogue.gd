extends Node

signal updated

var nodes: Dictionary = {}
var speakers: Dictionary = {}
var current_node_id := ""
var choices: Array = []
var feedback := ""
var state: Node
var interaction: Node
var failure_responses: Dictionary


func configure(content: Dictionary, puzzle_state: Node, controller: Node) -> void:
	state = puzzle_state
	interaction = controller
	failure_responses = content.puzzle.failure_responses
	for node in content.dialogue.nodes:
		nodes[node.id] = node
	for speaker in content.dialogue.speakers:
		speakers[speaker.id] = speaker.name
	state.dialogue_requested.connect(open)


func open(node_id: String) -> void:
	feedback = ""
	current_node_id = node_id
	interaction.modal_open = true
	refresh()


func refresh() -> void:
	choices.clear()
	if not current_node_id.is_empty():
		for choice in nodes[current_node_id].choices:
			if state.conditions_met(choice.requires):
				choices.append(choice)
	updated.emit()


func choose(index: int) -> void:
	if current_node_id.is_empty() or index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	var result: Dictionary = state.apply({"requires": choice.requires, "effects": choice.effects, "failure_text": failure_responses.use})
	if result.capacity or not result.text.is_empty():
		interaction.feedback_changed.emit(failure_responses.capacity if result.capacity else result.text)
	if not result.ok:
		feedback = failure_responses.capacity if result.capacity else result.text
		refresh()
		return
	# A start_dialogue effect has already opened its target after the transaction.
	for effect in choice.effects:
		if effect.type == "start_dialogue":
			return
	if choice.has("next_id"):
		open(choice.next_id)
	else:
		close()


func close() -> void:
	current_node_id = ""
	choices.clear()
	interaction.modal_open = false
	updated.emit()


func _input(event: InputEvent) -> void:
	if not current_node_id.is_empty() and event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()
