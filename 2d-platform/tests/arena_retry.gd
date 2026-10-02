extends SceneTree

var failures = 0

func _initialize():
	_run.call_deferred()

func check(condition, description):
	if not condition:
		failures += 1
		push_error(description)

func ticks(count = 3):
	for i in range(count):
		await physics_frame
		await process_frame

func _run():
	create_timer(120.0, true).timeout.connect(func():
		push_error("Arena retry checks timed out")
		quit(1)
	)
	for gems in [0, 1, 2]:
		change_scene_to_file("res://main.tscn")
		await scene_changed
		var run = current_scene
		var spawn = run.character.position
		# Pre-entry death retains the original full-level retry behavior.
		run.character.kill()
		run.retry()
		await scene_changed
		run = current_scene
		check(not run.arena_entered and run.character.position == spawn and run.collected_count == 0, "Pre-entry retry starts a fresh level")
		# Collect actual gems through physics before crossing the arena trigger.
		for index in range(gems):
			var gem = run.get_node("Collectibles/Gem%s" % (index + 1))
			run.character.position = gem.position - Vector2(44, 77)
			await ticks()
		run.character.take_damage()
		check(run.character.health == 2 and run.collected_count == gems, "Approach can arrive injured with its actual count")
		# Walk through entry; no manual invocation of its signal callback.
		run.character.position = Vector2(9200, 718)
		await ticks()
		Input.action_press("right")
		await ticks(25)
		Input.action_release("right")
		await ticks(12)
		check(run.arena_entered and run.arena_entry_count == gems and run.character.health == 3, "Physical entry restores health and snapshots count")
		check(run.character.invulnerability_remaining == 0 and run.character.player.modulate == Color.WHITE, "Entry clears damage feedback")
		check(not run.get_node("ArenaBoundary/CollisionShape2D").disabled and run.get_node("ArenaGate").visible, "Entry bounds the encounter visibly")
		# Backtracking cannot revisit the optional gems or overlap the gate.
		Input.action_press("left")
		await ticks(70)
		Input.action_release("left")
		check(run.character.position.x + 44 >= 9230 and run.character.health == 3, "Closing boundary leaves safe room and blocks backtracking")
		for ending in ["death", "pause", "death"]:
			run.character.take_damage()
			run.character.is_attacking = true
			run.character.attack_active = true
			run.character.hit_enemies[123] = true
			run.character.jump_buffer_remaining = 0.1
			if ending == "death":
				run.character.kill()
			else:
				var event = InputEventAction.new()
				event.action = "pause"
				event.pressed = true
				run._unhandled_input(event)
			var old_id = run.get_instance_id()
			Input.action_press("jump")
			var menu = run.death_ui if ending == "death" else run.pause_ui
			menu.get_node("Overlay/Panel/Buttons/Retry").pressed.emit()
			run.retry()
			await scene_changed
			# Let every scene_changed listener finish restoring the entry snapshot.
			await process_frame
			run = current_scene
			var character = run.character
			check(run.get_instance_id() != old_id and not paused and run.state == run.RunState.PLAYING, "Arena retry replaces and unpauses the scene once")
			check(character.position == run.get_node("ArenaSpawn").position and character.health == 3 and not character.is_dead, "Arena retry restores safe spawn and full health")
			check(character.velocity == Vector2.ZERO and not character.is_attacking and not character.attack_active and character.hit_enemies.is_empty() and character.invulnerability_remaining == 0 and character.jump_buffer_remaining == 0, "Arena retry clears combat and movement transients")
			check(run.arena_entered and run.collected_count == gems and run.arena_entry_count == gems and run.get_node("Collectibles").get_child_count() == 0, "Repeated arena retry preserves the snapshot without duplicate gems")
			check(run.hud.get_node("Margin/Info/Count").text == "Collected: %s" % gems, "Arena retry restores the HUD count")
			check(not run.death_ui.visible and not run.pause_ui.visible and not run.win_ui.visible, "Arena retry hides menus")
			await ticks(12)
			check(character.is_on_floor() and character.health == 3, "Arena spawn settles safely and a held confirm cannot jump")
			Input.action_release("jump")
			if DisplayServer.get_name() != "headless":
				for frame in range(4):
					await RenderingServer.frame_post_draw
				var hud_corner = root.get_texture().get_image().get_pixel(33, 25)
				check(hud_corner.r > 0.2 and hud_corner.r > hud_corner.b, "Native arena retry draws the gold HUD border")
			var camera = character.get_node("Camera2D")
			camera.force_update_scroll()
			var half_view = camera.get_viewport_rect().size / camera.zoom / 2
			check(camera.get_screen_center_position().x - half_view.x >= camera.limit_left - 1, "Retry camera starts within arena bounds")
		# Temporary exit remains reachable from the real retry spawn.
		Input.action_press("right")
		await ticks(280)
		Input.action_release("right")
		check(run.state == run.RunState.WON and run.collected_count == gems, "Arena retry can still reach the temporary exit")
		run.win_ui.get_node("Overlay/Panel/Buttons/Retry").pressed.emit()
		await scene_changed
		run = current_scene
		check(not run.arena_entered and run.collected_count == 0 and run.character.position == spawn and run.get_node("Collectibles").get_child_count() == 2, "Play Again clears the entry point and starts fresh")
		# Main Menu discards an entered checkpoint; Play creates a fresh level.
		run.character.position = run.get_node("ArenaSpawn").position
		await ticks()
		check(run.arena_entered, "New run can enter the arena again")
		run.character.kill()
		run.main_menu()
		await scene_changed
		current_scene._play()
		await scene_changed
		check(not current_scene.arena_entered and current_scene.collected_count == 0 and current_scene.character.position == spawn, "Main Menu and Play clear arena retry state")
	print("Arena entry/retry checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
