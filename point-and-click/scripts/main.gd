extends Node

const ContentLoader := preload("res://scripts/content_loader.gd")
@export var content_directory := "res://data"
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


func build_room() -> void:
	var background: Node2D = load(content.room.background_scene).instantiate()
	$Room.add_child(background)
	$Room.move_child(background, 0)
	for definition in content.room.hotspots:
		var visual: Node2D = load(definition.visual_scene).instantiate()
		visual.name = definition.id
		visual.position = Vector2(definition.position[0], definition.position[1])
		$Room/Props.add_child(visual)
		var area := Area2D.new()
		area.name = definition.id
		area.position = visual.position
		area.set_meta("hotspot_id", definition.id)
		area.input_pickable = false # Dispatch and hover belong to Step 02.
		var collision := CollisionPolygon2D.new()
		var vertices := PackedVector2Array()
		for point in definition.polygon:
			vertices.append(Vector2(point[0], point[1]))
		collision.polygon = vertices
		area.add_child(collision)
		$Room/Hotspots.add_child(area)
		var label := Label.new()
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
