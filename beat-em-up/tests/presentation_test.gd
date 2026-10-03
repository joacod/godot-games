extends SceneTree
## Real menu focus, bus values, confirmed cues and local effects across transitions.

const MAIN = preload("res://main.tscn")
var run: Node
var checks: int = 0
var failures: int = 0
var cues: Array[StringName] = []


func _initialize() -> void:
	_test.call_deferred()


func _test() -> void:
	run = MAIN.instantiate()
	root.add_child(run)
	await _frames(2)
	var music: AudioStreamPlayer = run.audio.music
	_check(music.playing and music.stream.loop and music.stream.loop_offset == 7.5,
		"one music player uses the source loop offset")
	_check(AudioServer.get_bus_count() == 3 and AudioServer.get_bus_send(1) == &"Master" \
		and AudioServer.get_bus_send(2) == &"Master", "Music and SFX route through Master")
	_check(AudioServer.get_bus_effect(0, 0) is AudioEffectHardLimiter, "Master has a peak limiter")
	_check(run.items.get_child(1).has_focus(), "title focuses Play")
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	_check(run.state == run.State.CONTROLS, "keyboard opens Controls")
	await _key(KEY_ESCAPE)
	await _key(KEY_DOWN)
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	_check(run.state == run.State.AUDIO and not paused, "keyboard opens title Audio")
	var sliders: Array[HSlider] = []
	for index in range(1, 4):
		sliders.append(run.items.get_child(index).get_node("Volume"))
	for index in range(3):
		var bus: StringName = [&"Master", &"Music", &"SFX"][index]
		_check(sliders[index].has_focus(), "%s receives keyboard focus" % bus)
		var before: float = run.audio.volumes[bus]
		await _key(KEY_LEFT)
		_check(run.audio.volumes[bus] == before - 5.0 \
			and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(index)), (before - 5.0) / 100.0),
			"focused volume changes the real bus")
		sliders[index].value = 0.0
		_check(AudioServer.is_bus_mute(index), "0 percent mutes %s" % bus)
		sliders[index].value = 100.0
		_check(not AudioServer.is_bus_mute(index) and AudioServer.get_bus_volume_db(index) == 0.0,
			"raising volume unmutes %s" % bus)
		await _joy(JOY_BUTTON_DPAD_DOWN)
	_check(run.items.get_child(4).has_focus(), "controller D-pad reaches Audio Back")
	await _joy(JOY_BUTTON_B)
	_check(run.state == run.State.TITLE, "east button backs out of Audio")
	await _joy(JOY_BUTTON_A)
	_check(run.state == run.State.PLAYING and not run.panel.visible \
		and not run.menu_background.visible and run.hud_panel.visible, "south starts clean gameplay")
	var street: Node2D = run.street
	var hero: CharacterBody2D = street.player
	hero.set_physics_process(false)
	var presentation: Node2D = street.get_node("Presentation")
	presentation.sound_requested.connect(func(cue: StringName) -> void: cues.append(cue))
	_check(not hero.get_node("Anchor").visible and not street.debug_bounds,
		"normal play hides actor anchors and the ground test outline")
	_check(hero.jump_height == 0.0 and music == run.audio.music and music.playing,
		"confirm does not jump and Play does not duplicate/restart music")
	_check(is_equal_approx(run.hero_bar.size.y, 10.0), "HUD health strip keeps its intended height")
	hero._start_strike(0)
	_check(cues == [&"swing"], "starting a strike emits one swing cue")
	hero.cancel_attack()
	cues.clear()
	hero.receive_hit(12, Vector2.LEFT)
	_check(cues == [&"hurt"] and presentation.impacts.size() == 1,
		"accepted hero damage emits one hurt cue and spark")
	hero.receive_hit(12, Vector2.LEFT)
	_check(cues.size() == 1 and presentation.impacts.size() == 1,
		"invulnerability rejects duplicate hurt feedback")
	await _frames(1)
	_check(run.hero_bar.value == 88 and run.hero_health.text.contains("88"), "HUD reflects actual health")
	var effect_time: float = presentation.impacts[0].time
	var game_voice: AudioStreamPlayer = run.audio.game_voices[0]
	run._show_menu(run.State.PAUSED)
	await _frames(5)
	_check(paused and presentation.impacts[0].time == effect_time and game_voice.stream_paused,
		"pause freezes impact lifetime and gameplay sound tails")
	_check(music.playing and music.volume_db == -18.0, "pause keeps one quieter music loop")
	run._open_submenu(run.State.AUDIO)
	await _frames(1)
	_check(paused and run.state == run.State.AUDIO, "pause Audio does not unfreeze gameplay")
	await _joy(JOY_BUTTON_B)
	_check(run.state == run.State.PAUSED and paused, "Audio Back returns to pause")
	await _key(KEY_ESCAPE)
	_check(run.state == run.State.PLAYING and not paused and hero._waiting_for_release \
		and not game_voice.stream_paused and music.volume_db == -10.0, "resume restores sound and release gating")
	await _frames(16)
	_check(presentation.impacts.is_empty(), "local spark expires after resume")
	cues.clear()
	var prop: Node2D = street.get_node("Actors/RecoveryProp")
	prop.receive_hit(10, Vector2.RIGHT)
	prop.receive_hit(10, Vector2.RIGHT)
	prop.receive_hit(10, Vector2.RIGHT)
	_check(cues == [&"hit", &"break"], "crate feedback occurs only on accepted hits/break")
	var food: Node2D = get_nodes_in_group("food_pickups")[0]
	hero.position = food.position
	food.try_collect()
	food.try_collect()
	_check(cues == [&"hit", &"break", &"pickup"], "food produces one collection cue")
	# Newly spawned enemies are watched only after their actor nodes are ready.
	hero.position = Vector2(560, 278)
	street._update_progress()
	var enemy: CharacterBody2D = street.encounters[0].enemies[0]
	for fighter in street.encounters[0].enemies:
		fighter.set_physics_process(false)
	cues.clear()
	enemy.receive_hit(10, Vector2.RIGHT)
	_check(cues == [&"hit"] and not enemy.get_node("Anchor").visible,
		"dynamically spawned enemies receive effects and hide diagnostics")
	# Boss protected damage does not pass through ordinary reaction handling.
	var boss: CharacterBody2D = street.BOSS.instantiate()
	boss.position = Vector2(2600, 278)
	boss.target = hero
	boss.ground_bounds = street.BOSS_BOUNDS
	street.get_node("Actors").add_child(boss)
	boss.set_physics_process(false)
	boss._start_attack(boss.Attack.SWEEP)
	cues.clear()
	boss.receive_hit(10, Vector2.LEFT)
	_check(cues == [&"hit"] and boss.state == boss.State.WINDUP,
		"noninterruptible boss hits still emit accepted impact feedback")
	# A run reset discards effect nodes/tails, retaining the same music and settings.
	run.audio.clear_game_sounds()
	for index in range(20): run.audio.play_game(&"hit")
	_check(run.audio.game_voices.size() == 6, "rapid impacts cannot create unbounded audio players")
	run._show_menu(run.State.PAUSED)
	run.start_run()
	await _frames(1)
	_check(not is_instance_valid(presentation) and run.street.get_node("Presentation").impacts.is_empty(),
		"Retry destroys old visual effects")
	var silent := true
	for voice in run.audio.game_voices: silent = silent and not voice.playing
	_check(silent and run.audio.music == music and run.audio.volumes[&"SFX"] == 100.0,
		"Retry stops old sounds without replacing music or volume choices")
	run.street.player.set_physics_process(false)
	run.street.player.receive_hit(1000, Vector2.LEFT)
	_check(run.state == run.State.DEAD and run.audio.menu_voice.playing, "Game Over has one audible result cue")
	for menu_state in [run.State.TITLE, run.State.CONTROLS, run.State.AUDIO, run.State.PAUSED, run.State.DEAD, run.State.VICTORY]:
		run._show_menu(menu_state)
		await _frames(1)
		_check(run.panel.position.y >= 0 and run.panel.get_rect().end.y <= 320 \
			and run.items.size.y <= run.panel.size.y - 32, "menu %d fits above navigation footer" % menu_state)
	run.main_menu()
	await _frames(1)
	_check(not paused and run.street == null and run.audio.music == music \
		and get_nodes_in_group("damage_receivers").is_empty(), "Main Menu leaves no actor/effect/run")
	print("Presentation checks: %d passed, %d failed" % [checks - failures, failures])
	run.queue_free()
	await _frames(2)
	quit(0 if failures == 0 else 1)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await _frames(1)
	event.pressed = false
	Input.parse_input_event(event)
	await _frames(1)


func _joy(button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	await _frames(1)
	event.pressed = false
	Input.parse_input_event(event)
	await _frames(1)


func _frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
