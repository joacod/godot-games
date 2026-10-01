extends SceneTree

# Godot --headless --path 2d-platform --fixed-fps 60 --script res://tests/combat.gd
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

func spawn_enemy(at: Vector2, moving: bool = false, hp: int = 2):
	var enemy = ENEMY.instantiate()
	enemy.position = at
	enemy.max_health = hp
	arena.add_child(enemy)
	enemy.set_physics_process(moving)
	return enemy

func press_attack(number: int):
	Input.action_press("attack%s" % number)
	await ticks(2)
	Input.action_release("attack%s" % number)

func wait_state(enemy, state):
	for frame in range(120):
		if enemy.combat_state == state:
			return
		await ticks(1)
	check(false, "Enemy reaches state %s" % state)

func _run():
	create_timer(40.0, true).timeout.connect(func():
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
	check(character.is_on_floor(), "Player lands on world")
	for facing in [1, -1]:
		for attack in [1, 2, 3]:
			character.position = Vector2(500, 754)
			character.velocity = Vector2.ZERO
			character.last_direction = facing
			var target = spawn_enemy(Vector2(500 + 96 * facing, 900), false, 10)
			var second = spawn_enemy(target.position, false, 10)
			var behind = spawn_enemy(Vector2(500 - 170 * facing, 900), false, 10)
			# Sprite origin is offset +16; probe 44 px beyond quick strike's edge.
			var reach_probe = spawn_enemy(Vector2(516 + 140 * facing, 900), false, 10)
			await ticks(3)
			await press_attack(attack)
			check(character.is_attacking and target.health == 10, "Harmless windup")
			paused = true
			var frame = character.player.frame
			await create_timer(0.1, true).timeout
			check(character.player.frame == frame and target.health == 10, "Paused windup freezes")
			paused = false
			await press_attack(attack % 3 + 1)
			check(character.player.animation == StringName("attacking%s" % attack), "Swing cannot be interrupted by another input")
			var damage = 2 if attack == 3 else 1
			var saw_hit = false
			var paused_strike = false
			for tick in range(90):
				if target.health < 10 and not saw_hit:
					saw_hit = true
					check(character.attack_active, "Damage matches visible striking frame")
					Input.action_press("left" if facing == 1 else "right")
					var before_x = character.position.x
					await ticks(1)
					Input.action_release("left" if facing == 1 else "right")
					check(character.position.x != before_x and character.attack_direction == facing and character.player.flip_h == (facing < 0), "Movement stays available with locked facing")
					character.velocity = Vector2.ZERO
				if character.attack_active and not paused_strike:
					paused = true
					var saved_health = target.health
					var saved_frame = character.player.frame
					await create_timer(0.1, true).timeout
					check(target.health == saved_health and character.player.frame == saved_frame, "Paused strike freezes damage and animation")
					paused = false
					paused_strike = true
				await ticks(1)
				if not character.is_attacking:
					break
			check(saw_hit and paused_strike, "Attack strikes in both directions")
			check(target.health == 10 - damage and second.health == 10 - damage, "Correct damage once per target per swing")
			check(behind.health == 10, "Cannot hit behind")
			check(reach_probe.health == (9 if attack == 1 else 10), "Only thrust reaches distant target")
			check(not character.attack_active and not character.is_attacking, "Recovery ends damage")
			for enemy in [target, second, behind, reach_probe]:
				enemy.queue_free()
			await ticks(2)

	# Actual physics overlap drives the forward enemy strike, not body contact.
	for facing in [1, -1]:
		character.position = Vector2(700 + facing * 60 - 44, 754)
		character.velocity = Vector2.ZERO
		character.health = 3
		character.invulnerability_remaining = 0.0
		var enemy = spawn_enemy(Vector2(700, 900), true)
		enemy.patrol_speed = 0
		await wait_state(enemy, enemy.CombatState.WINDUP)
		check(character.health == 3 and enemy.direction == facing, "Windup is harmless and faces target")
		paused = true
		var remaining = enemy.state_remaining
		await create_timer(0.1, true).timeout
		check(enemy.state_remaining == remaining, "Pause freezes enemy windup")
		paused = false
		await wait_state(enemy, enemy.CombatState.STRIKE)
		await ticks(3)
		check(character.health == 2, "Forward strike hits once")
		character.invulnerability_remaining = 0.0
		await ticks(3)
		check(character.health == 2, "Same strike cannot hit twice even without invulnerability")
		paused = true
		remaining = enemy.state_remaining
		await create_timer(0.1, true).timeout
		check(enemy.state_remaining == remaining, "Pause freezes enemy strike")
		paused = false
		await wait_state(enemy, enemy.CombatState.RECOVERY)
		paused = true
		remaining = enemy.state_remaining
		await create_timer(0.1, true).timeout
		check(enemy.state_remaining == remaining, "Pause freezes punishable recovery")
		paused = false
		character.last_direction = -facing
		await press_attack(2)
		await ticks(20)
		check(enemy.health == 1 and character.health == 2, "Quick strike punishes recovery without contact damage")
		enemy.take_damage(1)
		check(enemy.is_defeated and enemy.velocity == Vector2.ZERO and enemy.collision_layer == 0 and enemy.hit_players.is_empty(), "Defeat cancels all attacks immediately")
		await ticks(25)
		check(not is_instance_valid(enemy) and character.health == 2, "Defeated enemy cannot damage player")

	# Walk away after the tell; committed facing and stationary attack allow avoidance.
	character.position = Vector2(716, 754)
	character.velocity = Vector2.ZERO
	character.health = 3
	var avoid = spawn_enemy(Vector2(700, 900), true)
	avoid.patrol_speed = 0
	await wait_state(avoid, avoid.CombatState.WINDUP)
	Input.action_press("right")
	await ticks(30)
	Input.action_release("right")
	character.velocity = Vector2.ZERO
	await ticks(40)
	check(character.health == 3, "Telegraph leaves time to walk clear")
	avoid.queue_free()
	await ticks(2)
	character.position = Vector2(716, 754)
	character.velocity = Vector2.ZERO
	character.invulnerability_remaining = 0.0
	var jumper = spawn_enemy(Vector2(700, 900), true)
	jumper.patrol_speed = 0
	await wait_state(jumper, jumper.CombatState.WINDUP)
	await ticks(15)
	Input.action_press("jump")
	await ticks(25)
	Input.action_release("jump")
	check(character.health == 3 and not character.is_on_floor(), "Timed full jump clears enemy strike")
	jumper.queue_free()
	await ticks(2)
	character.position = Vector2(656, 754)
	character.velocity = Vector2.ZERO
	await ticks(5)
	var heavy_target = spawn_enemy(Vector2(752, 900), false)
	await ticks(3)
	character.last_direction = 1
	await press_attack(3)
	await ticks(30)
	check(heavy_target.is_defeated and heavy_target.collision_layer == 0, "One real heavy swing defeats the ordinary enemy")
	await ticks(25)
	check(not is_instance_valid(heavy_target), "Heavy defeat completes death animation")
	character.queue_free()
	await ticks(2)

	# Patrol and knockback remain bounded and cannot push the enemy over a ledge.
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
		check(patrol.position.x >= 2030 and patrol.position.x <= 2370 and patrol.position.y < 902, "Patrol stays on platform")
	check(visited_left and visited_right, "Patrol covers both sides")
	patrol.position = Vector2(2200, 900)
	patrol.patrol_left = -50
	patrol.patrol_right = 50
	patrol.take_damage(1)
	patrol.apply_knockback(200)
	var hit_x = patrol.position.x
	await ticks(6)
	check(patrol.position.x > hit_x and patrol.position.x - hit_x <= 32, "Real hit applies restrained knockback")
	paused = true
	var frozen_knockback = patrol.knockback_remaining
	await create_timer(0.1, true).timeout
	check(patrol.knockback_remaining == frozen_knockback, "Pause freezes knockback")
	paused = false
	for frame in range(90):
		await ticks(1)
		check(patrol.position.x >= 2150 and patrol.position.x <= 2250, "Knockback and patrol respect bounds")
	patrol.patrol_left = -400
	patrol.patrol_right = 400
	patrol.position = Vector2(2365, 900)
	patrol.apply_knockback(200)
	await ticks(15)
	check(patrol.position.x <= 2370 and patrol.position.y < 902, "Knockback cannot cross ledge")
	var wall = floor_at(Vector2(2270, 800), Vector2(32, 200))
	patrol.position = Vector2(2200, 900)
	patrol.direction = 1
	await ticks(45)
	check(patrol.position.x < 2224 and patrol.direction == -1, "Wall reverses patrol")
	wall.queue_free()
	arena.queue_free()
	await ticks(2)

	change_scene_to_file("res://main.tscn")
	await scene_changed
	for attempt in range(2):
		var run = current_scene
		var enemy = run.get_node("Enemy")
		check(enemy.health == 2 and enemy.combat_state == enemy.CombatState.PATROL and enemy.knockback_remaining == 0, "Fresh run clears enemy combat")
		enemy.take_damage(1)
		enemy.apply_knockback(200)
		await press_attack(3)
		run.character.kill()
		check(not run.character.attack_active and run.character.hit_enemies.is_empty(), "Death cancels player attack")
		run.retry()
		await scene_changed
		check(not paused and not current_scene.character.attack_active, "Retry replaces and unpauses combat")
	print("Step 4 combat checks: %s" % ("PASS" if failures == 0 else "FAIL (%s)" % failures))
	quit(0 if failures == 0 else 1)
