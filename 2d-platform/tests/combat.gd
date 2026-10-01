extends SceneTree

# Godot --headless --path 2d-platform --script res://tests/combat.gd
var failures = 0
var arena: Node2D
const PLAYER = preload("res://scenes/main_character.tscn")
const ENEMY = preload("res://scenes/enemy.tscn")

func _initialize():
	_run.call_deferred()

func check(condition: bool, description: String):
	if not condition:
		failures += 1
		push_error(description)

func ticks(count: int):
	for i in range(count):
		await physics_frame
		await process_frame

func floor_at(center: Vector2, size: Vector2):
	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.position = center
	body.add_child(collision)
	arena.add_child(body)
	return body

func spawn_enemy(at: Vector2, moving: bool = false):
	var enemy = ENEMY.instantiate()
	enemy.position = at
	arena.add_child(enemy)
	enemy.set_physics_process(moving)
	return enemy

func press_attack(number: int):
	Input.action_press("attack%s" % number)
	await ticks(2)
	Input.action_release("attack%s" % number)

func _run():
	create_timer(35.0, true).timeout.connect(func():
		push_error("Combat checks timed out")
		quit(1)
	)
	arena = Node2D.new()
	root.add_child(arena)
	floor_at(Vector2(800, 916), Vector2(1600, 32))
	var character = PLAYER.instantiate()
	character.position = Vector2(500, 754)
	arena.add_child(character)
	await ticks(5)
	check(character.is_on_floor(), "Combat test player lands on world")
	check(character.attack_hitbox.collision_layer == 8 and character.attack_hitbox.collision_mask == 4, "Attack detection uses named layers")
	for facing in [1, -1]:
		for attack in [1, 2, 3]:
			character.last_direction = facing
			var offset = 140 if facing == 1 else -124
			var target = spawn_enemy(Vector2(500 + offset, 900))
			var second = spawn_enemy(Vector2(500 + offset, 900))
			var behind = spawn_enemy(Vector2(500 - offset, 900))
			var distant = spawn_enemy(Vector2(500 + offset * 3, 900))
			await ticks(3)
			check(target.health == 2, "Idle overlap does not deal damage")
			await press_attack(attack)
			check(character.is_attacking and target.health == 2, "Attack starts with harmless windup")
			paused = true
			var windup_frame = character.player.frame
			var windup_progress = character.player.frame_progress
			await create_timer(0.12, true).timeout
			check(character.player.frame == windup_frame and character.player.frame_progress == windup_progress and target.health == 2, "Pause preserves harmless windup")
			paused = false
			await press_attack(attack % 3 + 1)
			check(character.player.animation == StringName("attacking%s" % attack), "Another attack cannot interrupt the swing")
			# Pause in windup and later in the strike window using real animation time.
			var did_pause = false
			var saw_hit = false
			for frame in range(60):
				if character.attack_active and not did_pause:
					paused = true
					var saved_frame = character.player.frame
					var saved_progress = character.player.frame_progress
					var saved_health = target.health
					await create_timer(0.15, true).timeout
					check(character.player.frame == saved_frame and character.player.frame_progress == saved_progress, "Pause freezes attack animation timing")
					check(target.health == saved_health, "Pause cannot deal attack damage")
					paused = false
					did_pause = true
				await ticks(1)
				if target.health == 1 and not saw_hit:
					saw_hit = true
					check(character.attack_active, "First damage occurs in striking frames")
					# Moving input cannot turn or replace the current swing.
					Input.action_press("left" if facing == 1 else "right")
					await ticks(1)
					Input.action_release("left" if facing == 1 else "right")
					character.velocity = Vector2.ZERO
					check(character.attack_direction == facing and character.player.flip_h == (facing < 0), "Swing facing stays fixed while moving")
				if not character.is_attacking:
					break
			check(saw_hit and did_pause, "Attack %s facing %s strikes and resumes" % [attack, facing])
			check(target.health == 1 and second.health == 1, "One swing hits each overlapping enemy exactly once")
			check(behind.health == 2 and distant.health == 2, "Attack cannot hit behind or out of reach")
			check(not character.is_attacking and not character.attack_active, "Attack completes and disables damage")
			character.position = Vector2(500, 754)
			character.last_direction = facing
			await ticks(3)
			await press_attack(attack)
			await create_timer(0.8, false).timeout
			check(not is_instance_valid(target) and not is_instance_valid(second), "Second swing defeats two-hit enemies and finishes death animation")
			behind.queue_free()
			distant.queue_free()
			await ticks(2)

	# Contact is tested through actual overlapping physics shapes, including sustained contact.
	character.position = Vector2(500, 754)
	var contact = spawn_enemy(Vector2(544, 900), true)
	contact.patrol_speed = 0.0
	await ticks(5)
	check(character.health == 2, "Enemy contact deals one damage")
	await create_timer(0.2, false).timeout
	check(character.health == 2, "Contact respects invulnerability")
	paused = true
	var cooldown = character.invulnerability_remaining
	var enemy_frame = contact.sprite.frame
	await create_timer(0.15, true).timeout
	check(character.invulnerability_remaining == cooldown and contact.sprite.frame == enemy_frame, "Pause freezes contact cooldown and enemy animation")
	paused = false
	await create_timer(1.0, false).timeout
	check(character.health == 1, "Sustained contact deals damage after invulnerability expires")
	contact.take_damage(2)
	check(contact.is_defeated and contact.velocity == Vector2.ZERO and contact.collision_layer == 0, "Defeat immediately stops motion and attack detection")
	await create_timer(1.1, false).timeout
	check(character.health == 1 and not is_instance_valid(contact), "Defeated enemy stops contact damage and is removed")
	character.kill()
	check(not character.attack_active and character.hit_enemies.is_empty(), "Death clears attack damage and hit history")
	character.queue_free()

	# Wide configured bounds force real ledge detection at both ends of an isolated platform.
	floor_at(Vector2(2200, 916), Vector2(400, 32))
	var patrol = spawn_enemy(Vector2(2200, 900), true)
	patrol.patrol_left = -400
	patrol.patrol_right = 400
	patrol.patrol_speed = 240
	var visited_left = false
	var visited_right = false
	for frame in range(240):
		await ticks(1)
		visited_left = visited_left or patrol.position.x < 2070
		visited_right = visited_right or patrol.position.x > 2330
		check(patrol.position.x >= 2030 and patrol.position.x <= 2370 and patrol.position.y < 902, "Patrol turns before falling off either ledge")
	check(visited_left and visited_right, "Patrol covers both sides of its platform")
	patrol.position = Vector2(2200, 900)
	patrol.patrol_left = -50
	patrol.patrol_right = 50
	for frame in range(90):
		await ticks(1)
		check(patrol.position.x >= 2150 and patrol.position.x <= 2250, "Patrol respects configured bounds")
	var wall = floor_at(Vector2(2270, 800), Vector2(32, 200))
	patrol.patrol_right = 400
	patrol.direction = 1
	await create_timer(0.7, false).timeout
	check(patrol.position.x < 2224 and patrol.direction == -1, "World wall collision reverses patrol")
	wall.queue_free()
	arena.queue_free()
	await ticks(2)

	# The real full-scene retry restores enemies and clears attack state.
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var enemy_spawn = current_scene.get_node("Enemy").position
	for attempt in range(2):
		var run = current_scene
		var enemy = run.get_node("Enemy")
		check(enemy.health == 2 and not enemy.is_defeated and enemy.position == enemy_spawn, "Run starts with a fresh enemy at its spawn")
		enemy.take_damage(2)
		var player = run.character
		Input.action_press("attack1")
		await ticks(2)
		Input.action_release("attack1")
		player.kill()
		run.retry()
		await scene_changed
		check(not paused and not current_scene.character.attack_active and current_scene.character.hit_enemies.is_empty(), "Retry resets combat and unpauses the new run")
	print("Step 3 combat checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
