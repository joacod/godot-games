extends Area2D

var hotspot_id := ""
var display_name := ""


func configure(definition: Dictionary) -> void:
	name = definition.id
	hotspot_id = definition.id
	display_name = definition.name
	position = Vector2(definition.position[0], definition.position[1])
	set_meta("hotspot_id", hotspot_id)
	var vertices := PackedVector2Array()
	for point in definition.polygon:
		vertices.append(Vector2(point[0], point[1]))
	$CollisionPolygon2D.polygon = vertices


func contains_point(world_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(to_local(world_point), $CollisionPolygon2D.polygon)
