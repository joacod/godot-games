extends SceneTree

# Godot --headless --path 2d-platform --script res://tests/game_loop.gd
var failures = 0

func _initialize():
	_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func ticks(count = 3):
	for i in range(count):
		await physics_frame
		await process_frame

func key_event(code, pressed = true):
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func button_event(index, pressed = true):
	var event = InputEventJoypadButton.new()
	event.device = 0
	event.button_index = index
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func _run():
	create_timer(18.0, true).timeout.connect(func():
		push_error("Game loop checks timed out")
		quit(1)
	)
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var run = current_scene
	var character = run.character
	check(run.collected_count == 0 and run.hud.get_node("Margin/Info/Health").text == "Health: 3 / 3", "HUD starts with full health and zero pickups")
	# Every gameplay action has explicit controller bindings and keeps its key.
	for action in ["left", "right", "jump", "run", "attack1", "attack2", "attack3", "pause"]:
		var has_key = false
		var has_pad = false
		for event in InputMap.action_get_events(action):
			has_key = has_key or event is InputEventKey
			has_pad = has_pad or event is InputEventJoypadButton or event is InputEventJoypadMotion
		check(has_key and has_pad, "%s has keyboard and gamepad mappings" % action)
	for binding in [["left", JOY_BUTTON_DPAD_LEFT], ["right", JOY_BUTTON_DPAD_RIGHT], ["jump", JOY_BUTTON_A], ["run", JOY_BUTTON_LEFT_SHOULDER], ["attack1", JOY_BUTTON_X], ["attack2", JOY_BUTTON_Y], ["attack3", JOY_BUTTON_B], ["pause", JOY_BUTTON_START]]:
		var event = InputEventJoypadButton.new()
		event.button_index = binding[1]
		check(InputMap.event_is_action(event, binding[0]), "Displayed controller button matches %s" % binding[0])
	# Reach a pickup through its real collision shape, then retry its signal callback.
	var pickup = run.get_node("Collectibles/Gem1")
	character.position = pickup.position - Vector2(44, 77)
	await ticks()
	check(run.collected_count == 1 and not is_instance_valid(pickup), "Physics overlap collects and removes a gem once")
	check(run.hud.get_node("Margin/Info/Count").text == "Collected: 1", "HUD updates collected count")
	character.take_damage()
	check(run.hud.get_node("Margin/Info/Health").text == "Health: 2 / 3", "HUD updates after damage")
	character.set_physics_process(false)
	character.is_attacking = true
	character.player.play("attacking3")
	character.player.set_frame_and_progress(2, 0.25)
	await key_event(KEY_ESCAPE)
	await key_event(KEY_ESCAPE, false)
	check(paused and run.state == run.RunState.PAUSED and run.pause_ui.visible, "Escape opens pause menu")
	var resume_button = run.pause_ui.get_node("Overlay/Panel/Buttons/Resume")
	var retry_button = run.pause_ui.get_node("Overlay/Panel/Buttons/Retry")
	check(resume_button.has_focus(), "Pause initially focuses Resume")
	var position_before = character.position
	var cooldown = character.invulnerability_remaining
	var animation_frame = character.player.frame
	var animation_progress = character.player.frame_progress
	var enemy_position = run.get_node("Enemy").position
	await create_timer(0.15, true).timeout
	check(character.position == position_before and character.invulnerability_remaining == cooldown, "Pause freezes player and invulnerability")
	check(character.player.frame == animation_frame and character.player.frame_progress == animation_progress and run.get_node("Enemy").position == enemy_position, "Pause freezes strikes and enemies")
	character.kill()
	run._on_exit_reached()
	check(not character.is_dead and not run.win_ui.visible and not run.death_ui.visible, "Paused run rejects death and exit transitions")
	await key_event(KEY_DOWN)
	await key_event(KEY_DOWN, false)
	check(retry_button.has_focus(), "Keyboard navigates menu without a mouse")
	await button_event(JOY_BUTTON_DPAD_UP)
	await button_event(JOY_BUTTON_DPAD_UP, false)
	check(resume_button.has_focus(), "Controller D-pad navigates menu")
	var menu_motion = InputEventJoypadMotion.new()
	menu_motion.axis = JOY_AXIS_LEFT_Y
	menu_motion.axis_value = 1.0
	Input.parse_input_event(menu_motion)
	await process_frame
	check(retry_button.has_focus(), "Controller stick navigates menu")
	menu_motion.axis_value = 0.0
	Input.parse_input_event(menu_motion)
	await process_frame
	await button_event(JOY_BUTTON_DPAD_UP)
	await button_event(JOY_BUTTON_DPAD_UP, false)
	await button_event(JOY_BUTTON_A)
	await button_event(JOY_BUTTON_A, false)
	check(not paused and run.state == run.RunState.PLAYING and not run.pause_ui.visible, "Controller A activates Resume")
	# Analog input moves at partial speed while facing remains a full direction.
	character.is_attacking = false
	var motion = InputEventJoypadMotion.new()
	motion.axis = JOY_AXIS_LEFT_X
	motion.axis_value = -0.75
	Input.parse_input_event(motion)
	await process_frame
	character.handle_movement(1.0 / 60.0)
	check(character.last_direction == -1 and character.velocity.x < 0, "Analog movement fixes facing to the swing's full direction")
	motion.axis_value = 0.0
	Input.parse_input_event(motion)
	await process_frame
	# Start button toggles pause; Enter activates focused Resume.
	await button_event(JOY_BUTTON_START)
	await button_event(JOY_BUTTON_START, false)
	check(paused and resume_button.has_focus(), "Start opens pause with initial focus")
	await key_event(KEY_ENTER)
	await key_event(KEY_ENTER, false)
	check(not paused, "Enter activates Resume")
	await key_event(KEY_ESCAPE)
	await key_event(KEY_ESCAPE, false)
	await key_event(KEY_ESCAPE)
	await key_event(KEY_ESCAPE, false)
	check(not paused, "Escape also resumes")
	# Win does not require all pickups or enemy defeat.
	character.position = run.get_node("Exit").position - Vector2(44, 77)
	await ticks()
	check(run.state == run.RunState.WON and paused and run.win_ui.visible, "Real exit overlap wins with an enemy alive and a pickup remaining")
	check(run.win_ui.get_node("Overlay/Panel/Buttons/Count").text == "Collected: 1", "Win displays this run's count")
	check(run.win_ui.get_node("Overlay/Panel/Buttons/Retry").has_focus(), "Win initially focuses Retry")
	character.kill()
	run._on_player_died()
	await key_event(KEY_ESCAPE)
	await key_event(KEY_ESCAPE, false)
	check(run.state == run.RunState.WON and not character.is_dead and not run.death_ui.visible and not run.pause_ui.visible, "Win rejects death and pause screens")
	# Each menu's connected Retry reloads all transient state.
	for ending in ["win", "pause", "death"]:
		var old_id = run.get_instance_id()
		var menu = run.win_ui if ending == "win" else run.pause_ui if ending == "pause" else run.death_ui
		menu.get_node("Overlay/Panel/Buttons/Retry").pressed.emit()
		run.retry()
		await scene_changed
		run = current_scene
		character = run.character
		check(run.get_instance_id() != old_id and not paused and run.state == run.RunState.PLAYING, "Retry from %s creates an unpaused run" % ending)
		check(run.collected_count == 0 and run.get_node("Collectibles").get_child_count() == 2 and character.health == 3 and run.get_node("Enemy").health == 2, "Retry resets count, pickups, health, and enemies")
		check(not character.is_attacking and not character.attack_active and character.invulnerability_remaining == 0 and character.velocity == Vector2.ZERO, "Retry resets movement and combat")
		check(not run.win_ui.visible and not run.pause_ui.visible and not run.death_ui.visible, "Retry hides all menus")
		if ending == "win":
			await key_event(KEY_ESCAPE)
			await key_event(KEY_ESCAPE, false)
		elif ending == "pause":
			character.kill()
			run._on_exit_reached()
			await button_event(JOY_BUTTON_START)
			await button_event(JOY_BUTTON_START, false)
			check(run.state == run.RunState.DEAD and not run.win_ui.visible and not run.pause_ui.visible, "Death rejects win and pause screens")
	print("Step 4 game loop checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
