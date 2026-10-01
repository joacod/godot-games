extends SceneTree

# Exercise the real player with a small floor, then actual run transitions.
var failures = 0
var fixture
var character

func _initialize():
	_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func ticks(count = 1):
	for i in range(count):
		await physics_frame
		await process_frame

func release_inputs():
	for action in ["left", "right", "run", "jump"]:
		Input.action_release(action)

func fresh_player():
	release_inputs()
	if is_instance_valid(fixture):
		fixture.queue_free()
		await ticks()
	fixture = Node2D.new()
	root.add_child(fixture)
	var floor_body = StaticBody2D.new()
	floor_body.position = Vector2(200, 410)
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(400, 20)
	floor_body.add_child(shape)
	fixture.add_child(floor_body)
	character = load("res://scenes/main_character.tscn").instantiate()
	character.position = Vector2(160, 254)
	fixture.add_child(character)
	await ticks(3)
	check(character.is_on_floor(), "Fixture starts grounded")

func jump_height(release_early):
	await fresh_player()
	var start_y = character.position.y
	var highest_y = start_y
	Input.action_press("jump")
	await ticks(3)
	if release_early:
		Input.action_release("jump")
	for i in range(60):
		await ticks()
		highest_y = minf(highest_y, character.position.y)
	check(character.is_on_floor(), "Jump returns to the floor")
	check(character.position.y > start_y - 1.0, "Held button cannot jump again on landing")
	return start_y - highest_y

func leave_ledge():
	Input.action_press("right")
	Input.action_press("run")
	for i in range(40):
		await ticks()
		if not character.is_on_floor():
			break
	Input.action_release("right")
	check(not character.is_on_floor(), "Walk off a real ledge")

func pause_event():
	var event = InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	current_scene._unhandled_input(event)

func _run():
	create_timer(30.0, true).timeout.connect(func():
		push_error("Movement checks timed out")
		quit(1)
	)
	var full_height = await jump_height(false)
	var short_height = await jump_height(true)
	check(full_height > 145.0 and short_height < full_height * 0.65, "Release makes a distinct short jump; hold retains full reach")
	print("Jump heights: full %.1f px, short %.1f px" % [full_height, short_height])

	await fresh_player()
	await leave_ledge()
	var ledge_window = character.coyote_remaining
	paused = true
	await ticks(20)
	check(ledge_window > 0.0 and character.coyote_remaining == ledge_window, "Pause freezes an active coyote window")
	paused = false
	await ticks(3)
	Input.action_press("jump")
	await ticks()
	check(character.velocity.y < -800.0, "Late ledge press jumps within coyote time")
	Input.action_release("jump")
	await ticks()
	Input.action_press("jump")
	await ticks()
	check(character.velocity.y > -500.0, "Second midair press cannot reuse coyote time")

	await fresh_player()
	await leave_ledge()
	await ticks(9)
	Input.action_press("jump")
	await ticks()
	check(character.velocity.y > 0.0, "Press after coyote expiration cannot jump")

	await fresh_player()
	Input.action_press("attack1")
	Input.action_press("right")
	Input.action_press("jump")
	await ticks()
	Input.action_release("attack1")
	check(character.is_attacking and character.velocity.y < -800.0 and character.velocity.x == character.walk_speed, "Movement and jumping remain available during attacks")

	# Press just before landing, with and without releasing before touchdown.
	for released in [false, true]:
		await fresh_player()
		character.position.y -= 100.0
		character.velocity.y = 250.0
		await ticks(9)
		Input.action_press("jump")
		await ticks()
		check(not character.is_on_floor() and character.jump_buffer_remaining > 0.0, "Early press waits for landing")
		if released:
			Input.action_release("jump")
		await ticks(5)
		check(character.velocity.y < 0.0 and character.jump_buffer_remaining == 0.0, "Landing consumes the buffered jump once")
		if released:
			check(character.velocity.y > -500.0, "Released buffer produces a short jump")
		await ticks(60)
		check(character.is_on_floor(), "Buffered jump does not repeat")

	await fresh_player()
	character.position.y -= 180.0
	await ticks(9)
	Input.action_press("jump")
	await ticks(35)
	check(character.is_on_floor() and character.velocity.y == 0.0, "Expired buffer cannot jump on a later landing")

	await fresh_player()
	character.position.y -= 100.0
	character.velocity.y = 250.0
	await ticks(9)
	Input.action_press("jump")
	await ticks()
	var buffer_before = character.jump_buffer_remaining
	var coyote_before = character.coyote_remaining
	var position_before = character.position
	paused = true
	await ticks(20)
	check(character.jump_buffer_remaining == buffer_before and character.coyote_remaining == coyote_before and character.position == position_before, "Pause freezes windows and movement")
	paused = false
	character.clear_jump_input()
	await ticks(10)
	check(character.is_on_floor(), "Discarded pause buffer cannot jump on resume")

	character.coyote_remaining = 0.1
	character.jump_buffer_remaining = 0.1
	character.jump_in_progress = true
	character.kill()
	check(character.velocity == Vector2.ZERO and character.coyote_remaining == 0.0 and character.jump_buffer_remaining == 0.0 and not character.jump_in_progress, "Death clears movement transients")
	fixture.queue_free()
	await ticks()
	release_inputs()

	change_scene_to_file("res://main.tscn")
	await scene_changed
	await ticks(30)
	var run = current_scene
	character = run.character
	check(character.is_on_floor(), "Actual run lands at spawn")
	pause_event()
	character.jump_buffer_remaining = 0.1
	Input.action_press("jump")
	run.pause_ui.get_node("Overlay/Panel/Buttons/Resume").pressed.emit()
	await ticks(3)
	check(character.is_on_floor() and character.jump_buffer_remaining == 0.0, "Resume confirm does not become a jump")
	Input.action_release("jump")
	await ticks()
	Input.action_press("jump")
	await ticks()
	check(character.velocity.y < -800.0, "Fresh press after Resume jumps normally")
	pause_event()
	run.retry()
	await scene_changed
	character = current_scene.character
	check(character.coyote_remaining == 0.0 and character.jump_buffer_remaining == 0.0 and character.velocity == Vector2.ZERO and not character.jump_in_progress, "Retry starts with clean transients")
	await ticks(30)
	check(character.is_on_floor(), "Held jump across Retry cannot launch at spawn")
	pause_event()
	current_scene.main_menu()
	await scene_changed
	current_scene._play()
	await scene_changed
	character = current_scene.character
	await ticks(30)
	check(character.is_on_floor() and character.jump_buffer_remaining == 0.0, "Main Menu and Play discard movement and held jump")
	release_inputs()
	print("Movement checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
