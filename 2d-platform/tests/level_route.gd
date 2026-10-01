extends SceneTree

# Exercise the actual level with movement/jump inputs, without teleporting along
# the route. This checks reachability, not human reaction time or game feel.
var failures = 0

func _initialize():
	_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func tick():
	await physics_frame
	await process_frame

func release_inputs():
	for action in ["right", "run", "jump"]:
		Input.action_release(action)

func route_surfaces(tile_map):
	# Find contiguous exposed tile tops, excluding optional shelves and end walls.
	var cells = tile_map.get_used_cells(0)
	var tops = []
	for cell in cells:
		if cell.y >= 46 and not cells.has(cell + Vector2i.UP):
			tops.append(cell)
	tops.sort_custom(func(a, b): return a.x < b.x)
	var surfaces = []
	for cell in tops:
		if not surfaces.is_empty() and surfaces[-1].end == cell.x * 16 and surfaces[-1].top == cell.y * 16:
			surfaces[-1].end += 16
		else:
			surfaces.append({"start": cell.x * 16, "end": (cell.x + 1) * 16, "top": cell.y * 16})
	return surfaces

func _run():
	for running in [false, true]:
		change_scene_to_file("res://main.tscn")
		await scene_changed
		var run = current_scene
		var character = run.character
		var route = route_surfaces(run.get_node("TileMap"))
		check(route.size() > 4, "The route contains successive jump sections")
		for i in range(60):
			await tick()
		check(character.is_on_floor() and character.health == 3, "Safe start lands with full health")
		var surface_index = 0
		var hazard_jumped = false
		var enemy_jumped = false
		var passing_enemy = false
		var jumps = 0
		var elapsed_ticks = 0
		Input.action_press("right")
		if running:
			Input.action_press("run")
		while run.state == run.RunState.PLAYING and elapsed_ticks < 9000:
			var center = character.position.x + 44.0
			if surface_index + 1 < route.size() and center >= route[surface_index + 1].start and character.is_on_floor() and absf(character.position.y + 146.0 - route[surface_index + 1].top) < 4.0:
				surface_index += 1
			var jump_now = false
			var enemy = run.get_node("Enemy")
			# A walking player can fight, or use the displayed run input to clear
			# the tall patrol. Exercise the latter without taking contact damage.
			if not running and not enemy_jumped and center >= enemy.position.x - 400.0:
				Input.action_press("run")
				passing_enemy = true
			if not running and enemy_jumped and center > enemy.position.x + 300.0:
				Input.action_release("run")
				passing_enemy = false
			if character.is_on_floor():
				if surface_index + 1 < route.size() and route[surface_index + 1].top <= route[surface_index].top and center >= route[surface_index].end - (180.0 if running else 80.0):
					jump_now = true
				var spike_x = run.get_node("Spikes").position.x
				if not hazard_jumped and center >= spike_x - (270.0 if running else 160.0):
					jump_now = true
					hazard_jumped = true
				if not enemy_jumped and center >= enemy.position.x - (270.0 if running or passing_enemy else 170.0):
					jump_now = true
					enemy_jumped = true
			if jump_now:
				Input.action_press("jump")
				jumps += 1
			await tick()
			Input.action_release("jump")
			elapsed_ticks += 1
			if elapsed_ticks % 120 == 0:
				var camera = character.get_node("Camera2D")
				camera.force_update_scroll()
				var half_view = camera.get_viewport_rect().size / camera.zoom / 2.0
				var camera_center = camera.get_screen_center_position()
				check(camera_center.x - half_view.x >= camera.limit_left - 1.0 and camera_center.x + half_view.x <= camera.limit_right + 1.0 and camera_center.y - half_view.y >= camera.limit_top - 1.0 and camera_center.y + half_view.y <= camera.limit_bottom + 1.0, "Camera rectangle stays inside the level throughout traversal")
		print("Finish position %s, surface %s / %s" % [character.position, surface_index, route.size()])
		release_inputs()
		check(run.state == run.RunState.WON, "%s route reaches the real exit without teleporting" % ("Running" if running else "Walking"))
		check(character.health == 3, "The enemy and spikes can be avoided without damage")
		check(run.collected_count == 0, "Elevated gems are optional")
		check(surface_index == route.size() - 1, "Every mandatory platform was traversed")
		print("%s traversal: %.1f simulated seconds, %s jumps, health %s" % ["Run" if running else "Walk with run jump past patrol", elapsed_ticks / 60.0, jumps, character.health])
		paused = false
	# The patrol can be avoided regardless of its direction or endpoint phase.
	for phase in [[-160.0, 1], [0.0, 1], [0.0, -1], [160.0, -1]]:
		change_scene_to_file("res://main.tscn")
		await scene_changed
		var run = current_scene
		var enemy = run.get_node("Enemy")
		enemy.position.x += phase[0]
		enemy.direction = phase[1]
		var character = run.character
		character.position = Vector2(enemy.position.x - 444.0, 718.0)
		for i in range(3):
			await tick()
		Input.action_press("right")
		Input.action_press("run")
		for i in range(30):
			if enemy.position.x - (character.position.x + 44.0) <= 270.0:
				break
			await tick()
		Input.action_press("jump")
		await tick()
		Input.action_release("jump")
		for i in range(50):
			await tick()
		check(character.health == 3 and character.position.x + 44.0 > enemy.position.x + 100.0, "Run jump clears patrol phase %s without contact damage" % [phase])
		release_inputs()
	# Each optional shelf is reachable by a run/jump from the preceding platform.
	for gem_name in ["Gem1", "Gem2"]:
		change_scene_to_file("res://main.tscn")
		await scene_changed
		var run = current_scene
		var character = run.character
		var gem = run.get_node("Collectibles/" + gem_name)
		var gem_x = gem.position.x
		# Set up on the preceding main platform; do not move onto the shelf.
		character.position = Vector2(gem_x - 488.0 - 44.0, 736.0 - 146.0)
		await tick()
		await tick()
		check(character.is_on_floor(), "Optional route begins on the main floor")
		Input.action_press("right")
		Input.action_press("run")
		Input.action_press("jump")
		await tick()
		Input.action_release("jump")
		for i in range(39):
			await tick()
		Input.action_release("right")
		for i in range(15):
			await tick()
		check(character.is_on_floor() and absf(character.position.y + 146.0 - 608.0) < 4.0, "Jump lands on optional shelf")
		check(run.collected_count == 1 and not is_instance_valid(gem), "Optional shelf gem can be collected")
		Input.action_press("right")
		for i in range(35):
			await tick()
		Input.action_release("right")
		for i in range(15):
			await tick()
		check(character.is_on_floor() and character.health == 3 and absf(character.position.y + 146.0 - 864.0) < 4.0, "Optional shelf returns safely to the main route")
		release_inputs()
	print("Step 5 level route checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
