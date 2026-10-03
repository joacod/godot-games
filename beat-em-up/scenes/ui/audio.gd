extends Node
## One music player across menu/run transitions; bounded, separate game/menu voices.

const SOUNDS := {
	&"swing": preload("res://assets/audio/swing.ogg"),
	&"hit": preload("res://assets/audio/hit.ogg"),
	&"hurt": preload("res://assets/audio/hurt.ogg"),
	&"break": preload("res://assets/audio/break.ogg"),
	&"pickup": preload("res://assets/audio/pickup.ogg"),
	&"focus": preload("res://assets/audio/focus.ogg"),
	&"confirm": preload("res://assets/audio/confirm.ogg"),
}
var music: AudioStreamPlayer
var game_voices: Array[AudioStreamPlayer] = []
var menu_voice: AudioStreamPlayer
var volumes: Dictionary = {&"Master": 80.0, &"Music": 45.0, &"SFX": 80.0}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music = AudioStreamPlayer.new()
	music.bus = &"Music"
	# Import settings repeat after the source author's 7.5-second intro.
	music.stream = preload("res://assets/audio/street.ogg")
	music.volume_db = -18.0
	add_child(music)
	music.play()
	for index in range(6):
		var voice := AudioStreamPlayer.new()
		voice.bus = &"SFX"
		voice.volume_db = -8.0
		add_child(voice)
		game_voices.append(voice)
	menu_voice = AudioStreamPlayer.new()
	menu_voice.bus = &"SFX"
	menu_voice.volume_db = -12.0
	add_child(menu_voice)
	for bus in volumes:
		set_volume(bus, volumes[bus])


func set_volume(bus: StringName, percent: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	var value := clampf(percent, 0.0, 100.0)
	volumes[bus] = value
	AudioServer.set_bus_mute(index, value == 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.001, value / 100.0)))


func set_playing(playing: bool) -> void:
	# Music continues quietly in menus; game tails freeze, menu cues remain usable.
	music.volume_db = -10.0 if playing else -18.0
	for voice in game_voices:
		voice.stream_paused = not playing


func clear_game_sounds() -> void:
	for voice in game_voices:
		voice.stop()


func play_game(cue: StringName) -> void:
	if get_tree().paused:
		return
	for voice in game_voices:
		if not voice.playing:
			voice.stream = SOUNDS[cue]
			voice.play()
			return


func play_menu(cue: StringName) -> void:
	menu_voice.stream = SOUNDS[cue]
	menu_voice.play()


func _exit_tree() -> void:
	clear_game_sounds()
	menu_voice.stop()
	music.stop()
