extends Node

const HotspotScene := preload("res://scenes/hotspot.tscn")
const ContentLoader := preload("res://scripts/content_loader.gd")
@export var content_directory := "res://data"
var lifecycle := "start"
var restart_pending := false
var content: Dictionary = {}
var content_errors: PackedStringArray = []


func _ready() -> void:
	var presentation: Control = $UI/Presentation
	$UI/Presentation/Title.text = presentation.theme.get_meta("title")
	$UI/Presentation/Subtitle.text = presentation.theme.get_meta("subtitle")
	$UI/Presentation/Footer.text = presentation.theme.get_meta("foundation_note")
	$Room.visible = false
	var result := ContentLoader.new().load_content(content_directory)
	content_errors = result.errors
	if not content_errors.is_empty():
		$UI/Presentation/ErrorPanel.show()
		$UI/Presentation/ErrorPanel/Scroll/Errors.text = "%s\n\n%s" % [presentation.theme.get_meta("content_error"), "\n".join(content_errors)]
		$UI/Presentation/Footer.hide()
		return
	content = result.content
	build_room()
	$Room.show()
	$UI/Presentation/Footer.hide()
	$Inventory.configure(content.items)
	$PuzzleState.configure(content.puzzle.initial_flags, $Inventory)
	$PuzzleState.changed.connect(_refresh_room)
	$Interaction.configure(content, $Room/Hotspots, $Inventory, $PuzzleState)
	$Dialogue.configure(content, $PuzzleState, $Interaction)
	$UI/Presentation/DialoguePanel.configure($Dialogue)
	$UI/Presentation/InteractionUI.configure($Interaction)
	$UI/Presentation/InteractionUI.show()
	$UI/Presentation/InventoryBar.configure($Inventory, $Interaction)
	$UI/Presentation/InventoryBar.show()
	$UI/Presentation/Menus.start_requested.connect(start_game)
	$UI/Presentation/Menus.resume_requested.connect(resume_game)
	$UI/Presentation/Menus.pause_requested.connect(pause_game)
	$UI/Presentation/Menus.restart_requested.connect(func(): restart_game.call_deferred())
	$PuzzleState.finished.connect(_complete_game)
	$UI/Presentation/Menus.show()
	$Interaction.modal_open = true
	$UI/Presentation/Menus.show_screen("start")
	_refresh_room()


func start_game() -> void:
	if lifecycle != "start" or content.is_empty():
		return
	lifecycle = "playing"
	$Interaction.modal_open = false
	$UI/Presentation/Menus.show_screen("")


func pause_game() -> void:
	if lifecycle != "playing":
		return
	lifecycle = "pause"
	$Interaction.modal_open = true
	$Dialogue.set_process_input(false)
	$UI/Presentation/DialoguePanel.hide()
	$UI/Presentation/Menus.show_screen("pause")


func resume_game() -> void:
	if lifecycle != "pause":
		return
	lifecycle = "playing"
	$Dialogue.set_process_input(true)
	$UI/Presentation/DialoguePanel.refresh()
	$Interaction.modal_open = not $Dialogue.current_node_id.is_empty()
	$UI/Presentation/Menus.show_screen("")


func _complete_game() -> void:
	lifecycle = "complete"
	$Interaction.cancel_selection()
	$Interaction.modal_open = true
	$UI/Presentation/Menus.show_screen("complete")
	_refresh_room()


func restart_game() -> Node:
	if restart_pending or content.is_empty():
		return null
	restart_pending = true
	var replacement: Node = load(scene_file_path).instantiate()
	replacement.content_directory = content_directory
	var parent := get_parent()
	var was_current := get_tree().current_scene == self
	var tree := get_tree()
	parent.remove_child(self)
	parent.add_child(replacement)
	if was_current:
		tree.current_scene = replacement
	replacement.start_game()
	queue_free()
	return replacement


func _unhandled_input(event: InputEvent) -> void:
	if lifecycle == "playing" and event.is_action_pressed("pause"):
		pause_game()
		get_viewport().set_input_as_handled()


func build_room() -> void:
	var background: Node2D = load(content.room.background_scene).instantiate()
	$Room.add_child(background)
	$Room.move_child(background, 0)
	for definition in content.room.hotspots:
		var visual: Node2D = load(definition.visual_scene).instantiate()
		visual.name = definition.id
		visual.position = Vector2(definition.position[0], definition.position[1])
		$Room/Props.add_child(visual)
		var area := HotspotScene.instantiate()
		area.configure(definition)
		$Room/Hotspots.add_child(area)
		var vertices: PackedVector2Array = area.get_node("CollisionPolygon2D").polygon
		var label := Label.new()
		label.name = definition.id + "Label"
		label.text = definition.name
		label.theme = $UI/Presentation.theme
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bounds := Rect2(vertices[0], Vector2.ZERO)
		for vertex in vertices:
			bounds = bounds.expand(vertex)
		label.position = visual.position + bounds.position + Vector2(-20, -24)
		label.size = Vector2(bounds.size.x + 40, 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Room.add_child(label)


func _refresh_room() -> void:
	var taken: bool = $PuzzleState.flags.oil_taken
	$Room/Props/oil.visible = not taken
	$Room/Hotspots/oil.visible = not taken
	$Room/oilLabel.visible = not taken
	var repaired: bool = $PuzzleState.flags.press_repaired
	$Room/Props/press/Shape4.position.y = -10.0 if repaired else 0.0
	$Room/pressLabel.text = $UI/Presentation.theme.get_meta("press_repaired") if repaired else $Room/Hotspots/press.display_name
	var complete: bool = $PuzzleState.completed
	for index in range(1, 6):
		$Room/Props/gate.get_node("Shape" + str(index)).visible = not complete
	$Room/gateLabel.text = $UI/Presentation.theme.get_meta("gate_open") if complete else $Room/Hotspots/gate.display_name
