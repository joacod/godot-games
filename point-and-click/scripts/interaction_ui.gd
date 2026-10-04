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
	interaction.hover_changed.connect(func(text: String): $Hover.text = text)
	interaction.feedback_changed.connect(func(text: String): $Description/Text.text = text)
	$Description/Text.text = theme.get_meta("interaction_hint")
	_show_verb(interaction.selected_verb)


func _show_verb(verb: String) -> void:
	for button_verb in buttons:
		buttons[button_verb].set_pressed_no_signal(button_verb == verb)
