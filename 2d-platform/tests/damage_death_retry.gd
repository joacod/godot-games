extends SceneTree

# Run from the repository root with Godot --headless --path 2d-platform
# --script res://tests/damage_death_retry.gd
var failures = 0
var death_events = 0
var health_events: Array[int] = []

func _initialize():
	_check_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func _on_death():
	death_events += 1

func _on_health_changed(value: int):
	health_events.append(value)

func _on_timeout():
	push_error("Step 2 checks timed out, including reload or Quit button handling")
	quit(1)

func _check_run():
	create_timer(12.0, true).timeout.connect(_on_timeout)
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var run = current_scene
	var character = run.get_node("CharacterBody2D")
	var spawn = character.position
	character.died.connect(_on_death)
	character.health_changed.connect(_on_health_changed)
	check(character.health == 3, "A run starts with three health points")
	check(character.collision_layer == 2 and character.collision_mask == 1, "Player uses player/world layers")
	var hazard = run.get_node("Spikes")
	check(hazard.collision_layer == 32 and hazard.collision_mask == 2, "Hazards detect only the player layer")

	character.take_damage(0)
	character.take_damage(-1)
	check(character.health == 3, "Non-positive damage is ignored")
	check(health_events.is_empty(), "Ignored damage emits no health change")
	character.take_damage()
	check(character.health == 2 and character.invulnerability_remaining > 0.0, "Damage starts invulnerability")
	check(character.player.modulate != Color.WHITE, "Damage has visible feedback")
	character.take_damage()
	check(character.health == 2, "Repeated immediate damage is ignored")
	check(health_events == [2], "A nonlethal hit emits once; invulnerable damage emits nothing")
	# Physics time drives invulnerability, so pausing freezes it.
	paused = true
	var remaining = character.invulnerability_remaining
	await create_timer(0.1, true).timeout
	check(character.invulnerability_remaining == remaining, "Invulnerability freezes while paused")
	paused = false
	await create_timer(1.2, false).timeout
	check(character.invulnerability_remaining == 0.0 and character.player.modulate == Color.WHITE, "Invulnerability and feedback expire")
	character.take_damage()
	check(character.health == 1, "Damage works again after invulnerability")
	await create_timer(1.2, false).timeout
	character.is_attacking = true
	character.velocity = Vector2(700, -900)
	character.take_damage()
	check(character.is_dead and character.health == 0, "Health depletion kills")
	check(health_events == [2, 1, 0], "Lethal damage emits zero health exactly once")
	check(character.velocity == Vector2.ZERO and not character.is_attacking, "Death cancels motion and attacks")
	check(paused and run.death_ui.visible, "Death freezes gameplay and shows menu")
	check(run.death_ui.get_node("Overlay/Panel/Buttons/Retry").has_focus(), "Retry has initial keyboard focus")
	character.kill()
	character.take_damage()
	run._on_player_died()
	check(death_events == 1, "Death is emitted once")
	check(health_events == [2, 1, 0], "Repeated death and damage emit no additional health changes")
	var frozen_position = character.position
	await create_timer(0.1, true).timeout
	check(character.position == frozen_position, "Death stops movement")

	for cause in ["spikes", "fall", "spikes"]:
		var old_instance = run.get_instance_id()
		# Exercise the actual button connection, including duplicate requests.
		run.death_ui.get_node("Overlay/Panel/Buttons/Retry").pressed.emit()
		run.retry()
		await scene_changed
		run = current_scene
		character = run.get_node("CharacterBody2D")
		character.died.connect(_on_death)
		character.health_changed.connect(_on_health_changed)
		check(run.get_instance_id() != old_instance, "Retry replaces the entire level")
		check(not paused and run.state == run.RunState.PLAYING and not run.death_ui.visible, "Retry resumes a clean run")
		check(character.position == spawn and character.velocity == Vector2.ZERO, "Retry restores spawn and velocity")
		check(character.health == 3 and not character.is_dead, "Retry restores health")
		check(not character.is_attacking and character.invulnerability_remaining == 0.0, "Retry clears combat state")
		check(character.player.modulate == Color.WHITE, "Retry clears damage feedback")
		character.take_damage()
		character.is_attacking = true
		if cause == "spikes":
			# Overlap the actual physics shape while still invulnerable.
			character.position = run.get_node("Spikes").position - Vector2(44, 93)
		else:
			# The fall zone spans every x, including beyond the tile boundaries.
			character.position = Vector2(-1000, run.fall_kill_y + 50)
		for frame in range(5):
			await physics_frame
			await process_frame
		check(character.is_dead and paused, "%s kills even during invulnerability" % cause)
		check(not character.is_attacking and character.velocity == Vector2.ZERO, "%s death clears combat/motion" % cause)
	check(death_events == 4, "Each run produces exactly one death event")
	check(health_events.count(0) == 4, "Lethal damage, spikes, and falls each emit zero health once")
	print("Step 2 damage/death/retry checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	if failures == 0:
		run.death_ui.get_node("Overlay/Panel/Buttons/Quit").pressed.emit()
	else:
		quit(1)
