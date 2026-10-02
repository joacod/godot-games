extends SceneTree
## Deterministic crowd arbitration plus live AI, pause and reset regressions.

const STREET = preload("res://scenes/enemies/fight_street.tscn")
var street: Node2D
var player: CharacterBody2D
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	street = STREET.instantiate()
	root.add_child(street)
	current_scene = street
	await _frames(2)
	player = street.player
	_stop()
	var grunt: CharacterBody2D = street.enemies[0]
	var second: CharacterBody2D = street.enemies[1]
	var bruiser: CharacterBody2D = street.enemies[2]
	_check(grunt.move_speed > bruiser.move_speed and grunt.max_health < bruiser.max_health \
		and grunt.strike_times.x < bruiser.strike_times.x, "types have different movement, health and tell")
	_check(street.claim_slot(grunt) and street.claim_slot(second) and not street.claim_slot(bruiser),
		"only two commitments allowed")
	grunt.receive_hit(1, Vector2.LEFT)
	_check(street.slots.size() == 1 and street.claim_slot(bruiser), "interruption releases a slot")
	second.receive_hit(1000, Vector2.LEFT)
	_check(not street.slots.has(second), "death releases a slot immediately")
	street.reset_test()
	_check(street.slots.is_empty() and not street.finished, "retry clears reservations and result")
	for enemy in street.enemies:
		_check(enemy.health == enemy.max_health and enemy.attack_time < 0.0 \
			and enemy._hit_targets.is_empty() and enemy.position == enemy._spawn_position,
			"retry restores every enemy and pending strike")
	for offset in [Vector2(35, 0), Vector2(-35, 0), Vector2(35, 20)]:
		street.reset_test()
		grunt.position = Vector2(300, 278)
		player.position = grunt.position + offset
		grunt._attack_facing = 1.0
		grunt.attack_time = 0.0
		street.claim_slot(grunt)
		grunt._tick_attack(0.2)
		_check(player.health == 100, "windup has no damage")
		grunt._tick_attack(0.21)
		_check(player.health == (88 if offset == Vector2(35, 0) else 100), "facing/depth committed strike " + str(offset))
		grunt._tick_attack(0.02)
		_check(player.health >= 88, "one hit per strike")
		grunt._tick_attack(0.7)
		_check(not street.slots.has(grunt) and grunt.attack_time < 0.0, "recovery releases slot")
	street.reset_test()
	grunt.position = Vector2(1000, 278)
	player.position = Vector2(960, 278)
	grunt.cooldown = 0.0
	grunt._physics_process(1.0 / 60.0)
	_check(grunt.attack_time < 0.0 and street.slots.is_empty(), "offscreen enemy cannot commit")
	street.reset_test()
	player.position = grunt.position
	grunt.cooldown = 1.0
	grunt._physics_process(1.0 / 60.0)
	_check(player.health == 100, "body overlap does no damage")
	street.reset_test()
	grunt.position = player.position + Vector2(38, 0)
	grunt.cooldown = 0.0
	grunt._physics_process(1.0 / 60.0)
	_check(grunt.state == grunt.State.WINDUP and street.slots.has(grunt), "live decision aligns and starts tell")
	grunt.set_physics_process(true)
	street.toggle_pause()
	var saved: float = grunt.attack_time
	var pos := grunt.position
	await _frames(12)
	_check(grunt.attack_time == saved and grunt.position == pos and player.health == 100,
		"pause freezes AI, tell and damage")
	street.reset_test()
	_check(not paused and grunt.attack_time < 0.0 and street.slots.is_empty(), "paused retry cancels strike")
	_stop()
	# Force a player-authored victory through the shared damage receiver.
	for enemy in street.enemies:
		enemy.position = player.position + Vector2(35, 0)
	for index in range(10):
		player._waiting_for_release = false
		player.cancel_attack()
		player.press_attack()
		player._tick_attack(0.25)
		for enemy in street.enemies:
			enemy.tick_reaction(0.25)
	_check(street.finished and street.outcome.text.begins_with("FIGHT CLEARED"), "hero can defeat mixed group")
	street.reset_test()
	player.receive_hit(1000, Vector2.LEFT)
	_check(street.finished and street.outcome.text.begins_with("DEFEATED") and street.slots.is_empty(),
		"death cancels fight commitments and offers retry")
	street.reset_test()
	_check(player.health == 100 and not street.outcome.visible, "death retry restores hero and UI")
	player.position.x = player.ground_bounds.position.x
	_check(street.approach_position(grunt).x > player.position.x + 16.0,
		"left-side enemy chooses reachable side at street endpoint")
	player.position.x = player.ground_bounds.end.x
	_check(street.approach_position(second).x < player.position.x - 16.0,
		"right-side enemy chooses reachable side at street endpoint")
	street.reset_test()
	# Run the actual scene AI against an idle hero: approach, bounded slots and loss.
	player.set_physics_process(true)
	for enemy in street.enemies:
		enemy.set_physics_process(true)
	player.invulnerability = 100.0
	var participated: Dictionary = {}
	for index in range(600):
		await _frames(1)
		for enemy in street.slots:
			participated[enemy] = true
	_check(participated.size() == 3, "both grunts and bruiser reach hero and receive attack opportunities")
	_check(street.enemies[1].position.distance_to(street.enemies[2].position) > 15.0,
		"crowd maintains separate ground positions")
	street.reset_test()
	var maximum := 0
	var started := false
	for index in range(1200):
		await _frames(1)
		maximum = maxi(maximum, street.slots.size())
		started = started or street.slots.size() > 0
		if street.finished:
			break
	_check(started and maximum <= 2, "live crowd approaches and respects two commitments")
	_check(player.health == 0 and street.finished, "idle hero loses live mixed fight")
	street.reset_test()
	await _frames(3)
	_check(player.health == 100 and street.slots.is_empty(), "live loss retry starts clean")
	print("Enemy checks: %d passed, %d failed" % [checks - failures, failures])
	street.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _stop() -> void:
	street.player.set_physics_process(false)
	for enemy in street.enemies:
		enemy.set_physics_process(false)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
