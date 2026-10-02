extends Control


# Screen-filling decoration. Only the horizontal camera position drives parallax;
# it never changes the camera, gameplay geometry, or any timing windows.
@export var follow_camera: bool = false
var camera_x: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(follow_camera)

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var next_x = camera.get_screen_center_position().x
		if next_x != camera_x:
			camera_x = next_x
			queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(1920, 1080))
	draw_rect(Rect2(0, 0, 1920, 1080), Color("101723"))
	for row in range(12):
		draw_rect(Rect2(0, row * 90, 1920, 90), Color("101723").lerp(Color("293747"), row / 16.0))
	# Stepped moon and clouds keep the background's edges on a pixel grid.
	for i in range(24):
		var star = Vector2(posmod(i * 293 + 80, 1920), 64 + posmod(i * 67, 288))
		draw_rect(Rect2(star, Vector2(3, 3)), Color("617078"))
	draw_colored_polygon(PackedVector2Array([Vector2(1456, 104), Vector2(1520, 104), Vector2(1520, 120), Vector2(1536, 120), Vector2(1536, 136), Vector2(1552, 136), Vector2(1552, 200), Vector2(1536, 200), Vector2(1536, 216), Vector2(1520, 216), Vector2(1520, 232), Vector2(1456, 232), Vector2(1456, 216), Vector2(1440, 216), Vector2(1440, 200), Vector2(1424, 200), Vector2(1424, 136), Vector2(1440, 136), Vector2(1440, 120), Vector2(1456, 120)]), Color("8c9c9b"))
	draw_rect(Rect2(1460, 128, 20, 16), Color("748787"))
	draw_rect(Rect2(1504, 184, 24, 24), Color("748787"))
	for i in range(7):
		var x = fposmod(i * 376.0 - camera_x * 0.025, 2300.0) - 200.0
		draw_rect(Rect2(x, 200 + (i % 3) * 64, 256, 16), Color("354252"))
		draw_rect(Rect2(x + 48, 184 + (i % 3) * 64, 128, 16), Color("354252"))
	_draw_towers(0.06, 480, Color("263441"), Color("30414b"))
	_draw_towers(0.14, 640, Color("192630"), Color("2b3d44"))

func _draw_towers(speed: float, spacing: int, stone: Color, trim: Color) -> void:
	var cycle = floori(camera_x * speed / spacing)
	for i in range(-1, 6):
		var x = i * spacing - fposmod(camera_x * speed, float(spacing))
		var top = 432 + posmod(i + cycle, 3) * 80
		draw_rect(Rect2(x, top, 176, 1080 - top), stone)
		draw_rect(Rect2(x + 12, top, 12, 1080 - top), trim)
		for merlon in range(4):
			draw_rect(Rect2(x + merlon * 48, top - 32, 32, 32), stone)
		for window_y in range(top + 64, 1000, 160):
			draw_rect(Rect2(x + 72, window_y, 24, 56), Color("101d27"))
			draw_rect(Rect2(x + 68, window_y + 8, 4, 48), trim)
			draw_rect(Rect2(x + 96, window_y + 8, 4, 48), trim)
			draw_rect(Rect2(x + 76, window_y - 8, 16, 8), trim)
			draw_rect(Rect2(x + 80, window_y + 4, 8, 36), Color("253641"))
		for seam_y in range(top + 48, 1080, 64):
			draw_rect(Rect2(x + 32, seam_y, 112, 2), stone.darkened(0.12))
			draw_rect(Rect2(x + 48 + posmod(floori(seam_y / 64.0), 2) * 48, seam_y, 2, 24), trim.darkened(0.15))
		# Broken distant curtain walls stay much darker than landing surfaces.
		draw_rect(Rect2(x + 176, top + 224, spacing - 176, 1080), stone)
		for brick in range(3):
			draw_rect(Rect2(x + 200 + brick * 64, top + 208, 32, 16), stone)
