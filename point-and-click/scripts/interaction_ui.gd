extends Control

var interaction: Node
var buttons: Dictionary = {}


func configure(controller: Node) -> void:
	interaction = controller
	var group := ButtonGroup.new()
	for verb in ["look", "use", "talk"]:
		var button: Button = $Verbs.get_node(verb.capitalize())
		button.text = theme.get_meta("verb_" + verb)
		button.button_group = group
		button.pressed.connect(interaction.select_verb.bind(verb))
		buttons[verb] = button
	interaction.verb_changed.connect(_show_verb)
	interaction.hover_changed.connect(_show_hover)
	interaction.selection_changed.connect(func(_item: String): _show_prompt())
	interaction.feedback_changed.connect(func(text: String): $Description/Text.text = text)
	$Description/Text.text = theme.get_meta("interaction_hint")
	_show_verb(interaction.selected_verb)


func _show_verb(verb: String) -> void:
	for button_verb in buttons:
		buttons[button_verb].set_pressed_no_signal(button_verb == verb)


func _show_hover(text: String) -> void:
	$Hover.text = text
	_show_prompt()


func _show_prompt() -> void:
	$ItemPrompt.text = ""
	if not interaction.selected_item.is_empty():
		var item_name: String = interaction.inventory.definitions[interaction.selected_item].name
		var target: String = interaction.hovered_name if not interaction.hovered_name.is_empty() else theme.get_meta("item_target")
		$ItemPrompt.text = theme.get_meta("item_prompt") % [item_name, target]
