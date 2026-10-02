extends SceneTree
## Actual boss/run scenes: attack rules, outcomes and transitions in every phase.

const MAIN = preload("res://main.tscn")
var run: Node
var checks: int = 0
var failures: int = 0
var results: int = 0


func _initialize() -> void:
	_test.call_deferred()


func _test() -> void:
	run = MAIN.instantiate()
	root.add_child(run)
	await _frames(2)
	var boss: CharacterBody2D = _arena()
	var street: Node2D = run.street
	var hero: CharacterBody2D = street.player
	_check(street.reached_entrance and street.camera.position.x == 2450.0 \
		and hero.ground_bounds == street.BOSS_BOUNDS, "safe boss entry locks arena and camera")
	_check(boss.health == 240 and boss.position.distance_to(hero.position) >= 80.0,
		"boss starts healthy and separated from hero")
	street._update_progress()
	_check(get_nodes_in_group("damage_receivers").size() == 8, "repeated boss entry cannot duplicate actors")
	# AI alternates the two designed attacks, committing facing and depth.
	boss.position = Vector2(2450, 278)
	hero.position = Vector2(2398, 278)
	boss.cooldown = 0.0
	boss._physics_process(0.0)
	_check(boss.state == boss.State.WINDUP and boss.attack == boss.Attack.SWEEP,
		"aligned hero triggers sweep")
	boss._tick_attack(2.0)
	boss.cooldown = 0.0
	boss._physics_process(0.0)
	_check(boss.state == boss.State.WINDUP and boss.attack == boss.Attack.CHARGE,
		"next commitment uses charge without extra phases")
	for kind in [boss.Attack.SWEEP, boss.Attack.CHARGE]:
		for phase in [boss.State.WINDUP, boss.State.ACTIVE, boss.State.RECOVERY]:
			boss = _arena()
			hero = run.street.player
			_set_phase(boss, kind, phase)
			var timer: float = boss.attack_time
			var pos: Vector2 = boss.position
			var facing: float = boss._attack_facing
			var health: int = boss.health
			_check(boss.receive_hit(18, Vector2.RIGHT, true), "boss accepts combo damage in phase %d/%d" % [kind, phase])
			_check(boss.health == health - 18 and boss.attack_time == timer \
				and boss.reaction == boss.Reaction.READY and boss.position == pos,
				"hit/knockdown cannot cancel or move committed boss")
			hero.position = boss.position + Vector2(52, 30)
			boss._tick_attack(0.01)
			_check(boss._attack_facing == facing and boss.position.y == pos.y,
				"moving hero cannot redirect committed attack")
			boss.receive_hit(1000, Vector2.RIGHT, true)
			_check(boss.health == 0 and boss.attack_time == -1.0 and boss._hit_targets.is_empty(),
				"death cancels boss attack and hit registry in every phase")
	# Coincident feet at a wall must not stall the boss's approach forever.
	for edge in [2180.0, 2720.0]:
		boss = _arena()
		hero = run.street.player
		boss.position = Vector2(edge, 278)
		hero.position = boss.position
		boss.cooldown = 0.0
		boss._physics_process(0.0)
		_check(boss.state == boss.State.WINDUP, "overlapping feet at either wall still commit a sweep")
		boss._tick_attack(0.56)
		_check(hero.health == 82, "sweep can hit coincident feet without body-contact damage")
	# Sweep damage only during active, once per strike; explicit depth/height/facing misses.
	for lane in ["hit", "depth", "height", "behind"]:
		boss = _arena()
		hero = run.street.player
		boss.position = Vector2(2450, 278)
		hero.position = Vector2(2398 if lane != "behind" else 2502, 278 if lane != "depth" else 308)
		hero.jump_height = 20.0 if lane == "height" else 0.0
		boss._facing = -1.0
		boss._start_attack(boss.Attack.SWEEP)
		boss._tick_attack(0.5)
		_check(hero.health == 100, "sweep tell deals no damage")
		boss._tick_attack(0.06)
		_check(hero.health == (82 if lane == "hit" else 100), "sweep respects %s eligibility" % lane)
		hero.invulnerability = 0.0
		boss._tick_attack(0.02)
		_check(hero.health == (82 if lane == "hit" else 100), "one sweep cannot hit repeatedly")
		boss._tick_attack(0.15)
		hero.position = boss.position + Vector2(-52, 0)
		boss._tick_attack(0.1)
		_check(hero.health == (82 if lane == "hit" else 100), "recovery deals no damage")
	# Charge stays on its line, hits once, and stops at either arena boundary.
	for facing in [-1.0, 1.0]:
		boss = _arena()
		hero = run.street.player
		boss.position = Vector2(2450, 278)
		hero.position = boss.position + Vector2(facing * 130, 0)
		boss._facing = facing
		boss._start_attack(boss.Attack.CHARGE)
		boss._tick_attack(0.84)
		_check(boss.position.x == 2450 and hero.health == 100, "charge tell is stationary and harmless")
		for index in range(90):
			boss._tick_attack(1.0 / 60.0)
			hero.invulnerability = 0.0
		_check(hero.health == 76 and hero.reaction == hero.Reaction.DOWN, "charge hits once and knocks hero down")
		_check(boss.position.x == (2180.0 if facing < 0 else 2720.0) \
			and boss.position.y == 278 and boss.state == boss.State.RECOVERY,
			"charge stops safely at arena edge with full recovery")
	boss = _arena()
	hero = run.street.player
	boss.position = Vector2(2450, 250)
	hero.position = Vector2(2398, 308)
	boss._facing = -1.0
	boss._start_attack(boss.Attack.CHARGE)
	for index in range(100):
		boss._tick_attack(1.0 / 60.0)
	_check(hero.health == 100 and boss.position.y == 250, "depth change avoids fixed charge lane")
	# The hero's real finisher can punish both recovery windows without shortening them.
	for kind in [0, 1]:
		boss = _arena()
		hero = run.street.player
		_set_phase(boss, kind, boss.State.RECOVERY)
		hero.position = boss.position + Vector2(-52, 0)
		hero._facing = 1.0
		hero._start_strike(2)
		var timer: float = boss.attack_time
		hero._tick_attack(hero.strike_times[2].x + 0.01)
		_check(boss.health == 222 and boss.state == boss.State.RECOVERY \
			and boss.attack_time == timer and boss.reaction == boss.Reaction.READY,
			"real finisher damages boss during full protected recovery window")
		boss._tick_attack(0.2)
		_check(boss.state == boss.State.RECOVERY, "boss remains open long enough for retaliation")
	# Pausing and leaving a run during either attack's tell/strike/recovery.
	for kind in [0, 1]:
		for phase in [1, 2, 3]:
			for exit_action in ["retry", "menu"]:
				boss = _arena()
				_set_phase(boss, kind, phase)
				boss.set_physics_process(true)
				var timer: float = boss.attack_time
				var pos: Vector2 = boss.position
				var hp: int = run.street.player.health
				run._show_menu(run.State.PAUSED)
				await _frames(10)
				_check(boss.attack_time == timer and boss.position == pos \
					and run.street.player.health == hp, "pause freezes all boss phases")
				run.resume_run()
				_check(not paused and run.street.player._waiting_for_release, "resume gates fresh gameplay input")
				run._show_menu(run.State.PAUSED)
				if exit_action == "menu":
					run.main_menu()
					await _frames(1)
					_check(run.state == run.State.TITLE and run.street == null \
						and get_nodes_in_group("damage_receivers").is_empty(), "Main Menu discards every boss phase")
				run.start_run()
				await _frames(1)
				_check(_fresh() and not is_instance_valid(boss), "retry/play rebuilds all state after boss phase")
	for kind in [0, 1]:
		for phase in [1, 2, 3]:
			boss = _arena()
			_set_phase(boss, kind, phase)
			run.street.player.receive_hit(1000, Vector2.LEFT)
			_check(run.state == run.State.DEAD and boss.attack_time == -1.0 \
				and boss._hit_targets.is_empty(), "hero death cancels either boss attack in every phase")
			run.start_run()
			await _frames(1)
			_check(_fresh(), "death retry restores route after every boss phase")
	# Death/result arbitration in both orders; victory is delayed until the corpse finishes.
	for boss_first in [true, false]:
		boss = _arena()
		street = run.street
		street.won.connect(func() -> void: results += 1)
		if boss_first:
			boss.receive_hit(1000, Vector2.RIGHT)
			street.player.receive_hit(1000, Vector2.LEFT)
		else:
			street.player.receive_hit(1000, Vector2.LEFT)
			boss.receive_hit(1000, Vector2.RIGHT)
		boss._physics_process(1.0)
		street._boss_defeated()
		_check(run.state == run.State.DEAD and results == 0, "player death wins simultaneous deaths in either order")
		run.start_run()
		await _frames(1)
		_check(_fresh(), "boss Game Over retry starts at full-health entrance")
	boss = _arena()
	street = run.street
	street.won.connect(func() -> void: results += 1)
	boss.receive_hit(1000, Vector2.RIGHT)
	_check(run.state == run.State.PLAYING, "boss health zero waits for death sequence")
	boss._physics_process(0.45)
	_check(run.state == run.State.PLAYING, "mid-death sequence does not show results")
	run._show_menu(run.State.PAUSED)
	var death_time: float = boss.reaction_time
	boss.set_physics_process(true)
	await _frames(10)
	_check(boss.reaction_time == death_time, "pause freezes boss death sequence")
	run.resume_run()
	boss.set_physics_process(false)
	boss._physics_process(0.46)
	_check(run.state == run.State.VICTORY and paused and results == 1, "finished boss death shows victory once")
	boss._physics_process(1.0)
	street._boss_defeated()
	_check(results == 1 and run.items.get_child(1).text == "Play Again", "duplicate defeat cannot repeat result")
	# Focused first button is usable with controller; held south does not jump.
	var south := InputEventJoypadButton.new()
	south.button_index = JOY_BUTTON_A
	south.pressed = true
	Input.parse_input_event(south)
	await _frames(2)
	_check(_fresh() and run.street.player._waiting_for_release \
		and run.street.player.jump_height == 0.0, "controller Play Again resets run without leaking confirm")
	south.pressed = false
	Input.parse_input_event(south)
	await _frames(2)
	run.main_menu()
	await _frames(1)
	_check(not paused and run.street == null and get_nodes_in_group("damage_receivers").is_empty(), "result Main Menu leaves no actor/timer")
	print("Boss checks: %d passed, %d failed" % [checks - failures, failures])
	run.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _arena() -> CharacterBody2D:
	run.start_run()
	var street: Node2D = run.street
	street.player.set_physics_process(false)
	for index in range(2):
		street.player.position.x = 540 if index == 0 else 1620
		street._update_progress()
		var encounter: Node2D = street.encounters[index]
		while not encounter.finished:
			for enemy in encounter.enemies:
				enemy.set_physics_process(false)
				if enemy.health > 0:
					enemy.receive_hit(1000, Vector2.LEFT)
			if not encounter.finished:
				encounter._physics_process(encounter.wave_delay)
	street.player.position.x = 2240
	street._update_progress()
	street.boss.set_physics_process(false)
	return street.boss


func _set_phase(boss: CharacterBody2D, kind: int, phase: int) -> void:
	boss.position = Vector2(2450, 278)
	boss._facing = -1.0
	boss.target.position = Vector2(2398, 308)
	boss._start_attack(kind)
	var timing: Vector3 = boss.sweep_times if kind == 0 else boss.charge_times
	if phase == boss.State.ACTIVE:
		boss._tick_attack(timing.x + 0.01)
	elif phase == boss.State.RECOVERY:
		boss._tick_attack(timing.x + timing.y + 0.01)


func _fresh() -> bool:
	var street: Node2D = run.street
	return not paused and run.state == run.State.PLAYING and street.player.health == 100 \
		and street.player.position == Vector2(160, 278) and street.camera.position.x == 320 \
		and not street.reached_entrance and street.boss == null and not street.completed \
		and street.active == null and not street.encounters[0].started \
		and not street.encounters[1].started


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
