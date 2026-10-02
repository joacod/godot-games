extends Camera2D


func _ready() -> void:
	get_viewport().size_changed.connect(_fit_viewport)
	_fit_viewport()

func _fit_viewport() -> void:
	# The project's expand stretch mode can make the viewport larger than the
	# level. Keep the whole visible rectangle inside the camera's pixel bounds.
	var viewport_size = get_viewport_rect().size
	var level_size = Vector2(limit_right - limit_left, limit_bottom - limit_top)
	var fit_zoom = maxf(1.0, maxf(viewport_size.x / level_size.x, viewport_size.y / level_size.y))
	zoom = Vector2.ONE * fit_zoom
