extends SceneTree

# Godot --headless --path 2d-platform --fixed-fps 60 --script res://tests/boss.gd
var failures = 0
var run
var character
var boss

func _initialize():
	_run.call_deferred()

func check(condition, description):
	if not condition:
		failures += 1
		push_error(description)

func ticks(count = 1):
	for i in range(count):
		await physics_frame
		await process_frame

func fresh():
	paused = false
	for action in ["left", "right", "jump", "attack1", "attack2", "attack3"]:
		Input.action_release(action)
	change_scene_to_file("res://main.tscn")
	await scene_changed
	run = current_scene
	character = run.character
	boss = run.boss
	character.position = run.get_node("ArenaSpawn").position
	await ticks(5)
	check(run.arena_entered and boss.active and run.get_node("BossHUD").visible, "Physical entry starts boss and health bar")

func wait_state(state):
	for i in range(400):
		if boss.combat_state == state:
			return
		await ticks()
	check(false, "Boss reaches state %s" % state)

func pause_check(description):
	var event = InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	run._unhandled_input(event)
	var remaining = boss.state_remaining
	var positions = [boss.waves[0].position, boss.waves[1].position]
	var hp = boss.health
	var frame = boss.sprite.frame
	await ticks(15)
	boss.take_damage()
	check(paused and boss.state_remaining == remaining and boss.health == hp and boss.sprite.frame == frame and boss.waves[0].position == positions[0] and boss.waves[1].position == positions[1], description)
	run.resume()

func capture(name):
	if DisplayServer.get_name() == "headless" or OS.get_environment("BOSS_CAPTURE_DIR").is_empty():
		return
	# Include the existing deferred HUD refresh after arena scene replacement.
	for i in range(6):
		await RenderingServer.frame_post_draw
	if name == "sweep-telegraph":
		var crown_at = boss.get_global_transform_with_canvas() * Vector2(0, -228)
		var pixel = root.get_texture().get_image().get_pixelv(Vector2i(crown_at))
		check(pixel.r > 0.7 and pixel.g > 0.6 and pixel.b < 0.5, "Native guardian crown is visibly gold")
	if name == "arena-retry":
		var hud_corner = root.get_texture().get_image().get_pixel(33, 25)
		check(hud_corner.r > 0.2 and hud_corner.r > hud_corner.b, "Native retry restores the player HUD alongside the boss bar")
	root.get_texture().get_image().save_png(OS.get_environment("BOSS_CAPTURE_DIR").path_join(name + ".png"))

func _run():
	create_timer(90.0, true).timeout.connect(func():
		push_error("Boss checks timed out")
		quit(1)
	)
	# Exit and damage are disabled before entry, even when callers bypass physics.
	change_scene_to_file("res://main.tscn")
	await scene_changed
	run = current_scene
	check(not run.boss.active and not run.get_node("Exit").unlocked, "Fresh run starts with dormant boss and sealed exit")
	run.boss.take_damage(99)
	run._on_exit_reached()
	check(run.boss.health == run.boss.max_health and run.state == run.RunState.PLAYING, "Skipping entry cannot damage boss or complete the demo")
	# Existing striking-frame contract: every attack, both directions, once per swing.
	for facing in [-1, 1]:
		for number in [1, 2, 3]:
			await fresh()
			boss.set_physics_process(false)
			character.position = Vector2(boss.position.x - 96 * facing, 718)
			character.last_direction = facing
			await ticks(3)
			Input.action_press("attack%s" % number)
			await ticks(2)
			Input.action_release("attack%s" % number)
			await ticks(55)
			check(boss.health == boss.max_health - (2 if number == 3 else 1), "Attack %s facing %s hits guardian once" % [number, facing])
			check(run.get_node("BossHUD/Panel/Info/Health").value == boss.health, "Health bar follows actual player hits")
	# Close sweep hits once, commits its facing, and allows moving out of reach.
	for facing in [-1, 1]:
		await fresh()
		character.position = Vector2(boss.position.x + facing * 155 - 44, 718)
		await wait_state(boss.CombatState.TELEGRAPH)
		check(boss.facing == facing and character.health == 3, "Sweep tell commits facing without damage")
		await pause_check("Pause freezes sweep telegraph and damage")
		await capture("sweep-telegraph")
		await wait_state(boss.CombatState.ATTACK)
		await ticks(3)
		check(character.health == 2, "Sweep damages player inside visible strike")
		character.invulnerability_remaining = 0
		await ticks(3)
		check(character.health == 2, "Sweep hits each player once even after invulnerability clears")
		await pause_check("Pause freezes sweep attack")
		await wait_state(boss.CombatState.RECOVERY)
		await pause_check("Pause freezes sweep recovery")
		var hp = boss.health
		boss.take_damage(2)
		check(boss.health == hp - 2 and character.health == 2, "Recovery is punishable without contact damage")
		await fresh()
		character.position = Vector2(boss.position.x + facing * 155 - 44, 718)
		await wait_state(boss.CombatState.TELEGRAPH)
		Input.action_press("right" if facing == 1 else "left")
		await ticks(48)
		Input.action_release("right" if facing == 1 else "left")
		check(character.health == 3 and boss.facing == facing, "Walking away during sweep tell avoids committed strike")
	# Both shockwave directions deal damage on the floor and permit actual full jumps.
	for side in [-1, 1]:
		for jumping in [false, true]:
			await fresh()
			character.position = Vector2(boss.position.x + side * 330 - 44, 718)
			await wait_state(boss.CombatState.RECOVERY)
			await wait_state(boss.CombatState.TELEGRAPH)
			check(boss.attack == boss.Attack.SHOCKWAVE, "Pattern alternates sweep and ground wave")
			await pause_check("Pause freezes shockwave tell")
			while boss.state_remaining > 0.12:
				await ticks()
			if jumping:
				Input.action_press("jump")
			await wait_state(boss.CombatState.ATTACK)
			await ticks(8)
			await capture("ground-wave")
			await pause_check("Pause freezes travelling shockwaves")
			# Resume clears held jump arming, but preserves the jump already underway.
			await ticks(32)
			Input.action_release("jump")
			check(character.health == (3 if jumping else 2), "Ground wave side %s is %s" % [side, "jumpable" if jumping else "damaging on the floor"])
			await wait_state(boss.CombatState.RECOVERY)
			check(not boss.waves[0].visible and not boss.waves[1].visible, "Recovery removes projectiles")
	# Win an entire encounter through inputs, approaching only during recovery.
	await fresh()
	character.position = Vector2(boss.position.x + 286, 718)
	for frame in range(5000):
		Input.action_release("attack2")
		if boss.is_defeated or character.is_dead:
			break
		var approaching = boss.combat_state == boss.CombatState.RECOVERY
		Input.action_release("left")
		Input.action_release("right")
		if approaching:
			if character.position.x > boss.position.x + 80:
				Input.action_press("left")
			elif not character.is_attacking:
				Input.action_press("attack2")
		elif character.position.x < boss.position.x + 286:
			Input.action_press("right")
		if boss.combat_state == boss.CombatState.TELEGRAPH and boss.attack == boss.Attack.SHOCKWAVE and boss.state_remaining <= 0.12:
			Input.action_press("jump")
		elif character.velocity.y >= 0:
			Input.action_release("jump")
		await ticks()
	for action in ["left", "right", "jump", "attack2"]:
		Input.action_release(action)
	check(boss.is_defeated and character.health == 3, "Input-driven observe/avoid/punish fight defeats both phases without damage")
	# Phase change changes only recovery; tells keep their full duration.
	await fresh()
	boss.take_damage(6)
	check(run.get_node("BossHUD/Panel/Info/Name").text.contains("PHASE 2"), "Half health announces phase two")
	await wait_state(boss.CombatState.TELEGRAPH)
	check(boss.state_remaining >= boss.sweep_telegraph - 0.02, "Phase two retains full sweep tell")
	await wait_state(boss.CombatState.RECOVERY)
	check(absf(boss.state_remaining - boss.phase_two_recovery) < 0.02, "Phase two moderately shortens recovery")
	# Death in flight clears waves. Retry reconstructs the encounter, bar, and gates.
	await wait_state(boss.CombatState.TELEGRAPH)
	await wait_state(boss.CombatState.ATTACK)
	await ticks(4)
	character.kill()
	check(not boss.active and boss.state_remaining == 0 and not boss.waves[0].visible and not boss.waves[1].visible, "Death removes all active boss timing and projectiles")
	run.retry()
	await scene_changed
	await process_frame
	run = current_scene
	character = run.character
	boss = run.boss
	check(boss.active and boss.health == boss.max_health and not boss.is_defeated and not run.boss_defeated and character.health == 3, "Arena retry restores boss and player health")
	check(not run.get_node("ExitBoundary/CollisionShape2D").disabled and not run.get_node("ArenaBoundary/CollisionShape2D").disabled and not run.get_node("Exit").unlocked and run.get_node("BossHUD/Panel/Info/Health").value == boss.max_health, "Arena retry resets gates, exit, and health bar")
	await capture("arena-retry")
	# Physical exit boundary cannot be passed while the guardian lives.
	character.position = Vector2(10700, 718)
	Input.action_press("right")
	await ticks(40)
	Input.action_release("right")
	check(character.position.x + 44 < 10832 and run.state == run.RunState.PLAYING, "Closed exit gate physically stops player without completing")
	# Defeat during shockwave attack clears attacks and opens both gates once.
	character.position = run.get_node("ArenaSpawn").position
	await wait_state(boss.CombatState.RECOVERY)
	await wait_state(boss.CombatState.TELEGRAPH)
	await wait_state(boss.CombatState.ATTACK)
	var defeat_count = [0]
	boss.defeated.connect(func(): defeat_count[0] += 1)
	boss.take_damage(99)
	boss.take_damage(99)
	await ticks(3)
	check(defeat_count[0] == 1 and run.boss_defeated and not boss.active and boss.collision_layer == 0 and not boss.waves[0].visible and not boss.waves[1].visible, "Defeat fires once and removes attack/damage detection")
	check(run.get_node("Exit").unlocked and run.get_node("ExitBoundary/CollisionShape2D").disabled and run.get_node("ArenaBoundary/CollisionShape2D").disabled and not run.get_node("ExitGate").visible and not run.get_node("BossHUD").visible, "Defeat visibly opens boundaries and exit")
	check(run.state == run.RunState.PLAYING, "Boss defeat alone does not complete the demo")
	await capture("defeated")
	# Walk to the unlocked exit with actual input; completion remains terminal.
	Input.action_press("right")
	await ticks(280)
	Input.action_release("right")
	check(run.state == run.RunState.WON and run.win_ui.visible and run.win_ui.get_node("Overlay/Panel/Buttons/Title").text == "Demo Complete", "Walking to unlocked exit shows Demo Complete")
	await capture("demo-complete")
	run._on_player_died()
	run._on_exit_reached()
	character.kill()
	check(run.state == run.RunState.WON and not run.death_ui.visible and not character.is_dead, "Completion rejects repeated exit/death")
	run.retry()
	await scene_changed
	run = current_scene
	check(not run.arena_entered and not run.boss.active and not run.boss_defeated and run.collected_count == 0 and not run.get_node("Exit").unlocked, "Play Again resets level and boss gate")
	print("Boss encounter checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
