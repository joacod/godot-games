extends SceneTree

# Godot --headless --path 2d-platform --script res://tests/menu_navigation.gd
var failures = 0

func _initialize():
	_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func key_event(code, pressed = true):
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func click_button(button):
	await process_frame
	await process_frame
	var motion = InputEventMouseMotion.new()
	motion.position = button.get_global_rect().get_center()
	root.push_input(motion, true)
	await process_frame
	var event = InputEventMouseButton.new()
	event.position = button.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event.pressed = false
	root.push_input(event, true)
	await process_frame

func capture(name):
	if DisplayServer.get_name() == "headless" or OS.get_environment("MENU_CAPTURE_DIR").is_empty():
		return
	for i in range(6):
		await process_frame
		RenderingServer.force_draw(false)
	if name == "level" or name.begins_with("fresh-"):
		var hud_corner = root.get_texture().get_image().get_pixel(33, 25)
		check(hud_corner.r > 0.2 and hud_corner.r > hud_corner.b, "Native title/Play restores the player HUD in %s" % name)
	root.get_texture().get_image().save_png(OS.get_environment("MENU_CAPTURE_DIR").path_join(name + ".png"))

func _run():
	create_timer(18.0, true).timeout.connect(func():
		push_error("Menu navigation checks timed out, including Quit handling")
		quit(1)
	)
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/title.tscn", "Startup is the dedicated title scene")
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	var title = current_scene
	check(title.menu.visible and not title.help.visible and title.menu.get_node("Play").has_focus(), "Title opens with Play focused")
	await capture("title")
	await key_event(KEY_DOWN)
	await key_event(KEY_DOWN, false)
	check(title.menu.get_node("HowToPlay").has_focus(), "Keyboard navigates title buttons")
	await key_event(KEY_ENTER)
	await key_event(KEY_ENTER, false)
	check(title.help.visible and not title.menu.visible and title.help.get_node("Back").has_focus(), "Enter opens help with Back focused")
	await capture("help")
	await key_event(KEY_ESCAPE)
	await key_event(KEY_ESCAPE, false)
	check(title.menu.visible and not title.help.visible and title.menu.get_node("HowToPlay").has_focus(), "Escape returns from help and restores focus")
	await click_button(title.menu.get_node("HowToPlay"))
	check(title.help.visible, "Mouse opens How to Play")
	await click_button(title.help.get_node("Back"))
	check(title.menu.visible and not title.help.visible, "Mouse Back button returns to title")
	var last_run_id = 0
	for ending in ["pause", "death", "arena-pause", "arena-death", "win"]:
		title.menu.get_node("Play").pressed.emit()
		title._play()
		await scene_changed
		var run = current_scene
		check(run.get_instance_id() != last_run_id and not paused and run.state == run.RunState.PLAYING, "Play creates a fresh unpaused run")
		last_run_id = run.get_instance_id()
		check(run.collected_count == 0 and run.character.health == 3 and run.get_node("Enemy").health == 2 and run.get_node("Collectibles").get_child_count() == 2, "Play resets health, enemy, gems, and count")
		check(run.character.velocity == Vector2.ZERO and not run.character.is_attacking and run.character.invulnerability_remaining == 0, "Play resets movement and combat")
		check(not run.pause_ui.visible and not run.death_ui.visible and not run.win_ui.visible, "Fresh run hides gameplay menus")
		check(not run.arena_entered and not run.boss.active and not run.boss_defeated and not run.get_node("Exit").unlocked and not run.get_node("BossHUD").visible, "Main Menu/Play resets arena, boss, bar, and sealed exit")
		await capture("level" if ending == "pause" else "fresh-" + ending)
		run._on_collected()
		run.character.take_damage()
		var old_boss = run.boss
		var old_wave = old_boss.waves[0]
		if ending.begins_with("arena-"):
			run.character.position = run.get_node("ArenaSpawn").position
			for i in range(400):
				await physics_frame
				await process_frame
				if old_boss.waves[0].visible:
					break
			check(run.arena_entered and old_boss.active and old_wave.visible, "Arena navigation starts with a live boss shockwave")
		var menu
		if ending in ["pause", "arena-pause"]:
			await key_event(KEY_ESCAPE)
			await key_event(KEY_ESCAPE, false)
			menu = run.pause_ui
		elif ending in ["death", "arena-death"]:
			run.character.kill()
			menu = run.death_ui
		else:
			run._on_arena_entered(run.character)
			run.boss.take_damage(run.boss.max_health)
			run._on_exit_reached()
			menu = run.win_ui
		check(paused and menu.visible, "%s menu pauses the level" % ending)
		await capture(ending)
		menu.get_node("Overlay/Panel/Buttons/MainMenu").pressed.emit()
		run.main_menu()
		await scene_changed
		title = current_scene
		check(not paused and title.menu.get_node("Play").has_focus(), "Main Menu from %s clears pause and focuses Play" % ending)
		check(not is_instance_valid(run), "Main Menu frees the previous run")
		check(not is_instance_valid(old_boss) and not is_instance_valid(old_wave), "Main Menu frees the guardian and its projectiles from %s" % ending)
	# Verify native controller confirm on the title, then its Quit connection.
	await process_frame
	var pad = InputEventJoypadButton.new()
	pad.device = 0
	pad.button_index = JOY_BUTTON_A
	pad.pressed = true
	Input.parse_input_event(pad)
	await process_frame
	pad.pressed = false
	Input.parse_input_event(pad)
	await scene_changed
	var run = current_scene
	run._on_arena_entered(run.character)
	run.boss.take_damage(run.boss.max_health)
	run._on_exit_reached()
	run.win_ui.get_node("Overlay/Panel/Buttons/MainMenu").pressed.emit()
	await scene_changed
	print("Menu navigation checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	if failures == 0:
		current_scene.menu.get_node("Quit").pressed.emit()
	else:
		quit(1)
