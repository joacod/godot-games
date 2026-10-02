extends Node


# Falling past this horizontal line is lethal at any x position.
@export var fall_kill_y = 1120.0
enum RunState {PLAYING, DEAD, RETRYING, PAUSED, WON}
var state = RunState.PLAYING
var collected_count = 0
var arena_entered = false
var arena_entry_count = 0
@onready var character = $CharacterBody2D
@onready var death_ui = $DeathUI
@onready var pause_ui = $PauseUI
@onready var win_ui = $WinUI
@onready var hud = $HUD

func _ready():
	# Only this transition owner and menus run while gameplay is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child.process_mode == Node.PROCESS_MODE_INHERIT:
			child.process_mode = Node.PROCESS_MODE_PAUSABLE
	character.died.connect(_on_player_died)
	character.health_changed.connect(_update_health)
	for menu in [death_ui, pause_ui, win_ui]:
		menu.get_node("Overlay/Panel/Buttons/Retry").pressed.connect(retry)
		menu.get_node("Overlay/Panel/Buttons/Quit").pressed.connect(_quit)
		menu.get_node("Overlay/Panel/Buttons/MainMenu").pressed.connect(main_menu)
	pause_ui.get_node("Overlay/Panel/Buttons/Resume").pressed.connect(resume)
	for pickup in $Collectibles.get_children():
		pickup.collected.connect(_on_collected)
	$Exit.reached.connect(_on_exit_reached)
	$ArenaEntry.body_entered.connect(_on_arena_entered)
	_update_health(character.health)
	_update_count()

func _on_arena_entered(body):
	if body != character or arena_entered or state != RunState.PLAYING or character.is_dead:
		return
	arena_entered = true
	arena_entry_count = collected_count
	character.health = character.max_health
	character.invulnerability_remaining = 0.0
	character.player.modulate = Color.WHITE
	character.health_changed.emit(character.health)
	_bound_arena()

func _bound_arena():
	# Entry detection starts beyond the player's radius, clear of the closing wall.
	$ArenaBoundary/CollisionShape2D.set_deferred("disabled", false)
	$ArenaGate.show()
	character.get_node("Camera2D").limit_left = int($ArenaBoundary.position.x - 16)
	character.get_node("Camera2D")._fit_viewport()

func _unhandled_input(event):
	if event.is_action_pressed("pause") and not event.is_echo():
		if state == RunState.PLAYING:
			state = RunState.PAUSED
			get_tree().paused = true
			pause_ui.show()
			pause_ui.get_node("Overlay/Panel/Buttons/Resume").grab_focus()
		elif state == RunState.PAUSED:
			resume()
		get_viewport().set_input_as_handled()

func _physics_process(_delta):
	if state == RunState.PLAYING and character.global_position.y > fall_kill_y:
		character.kill()

func _update_health(value):
	hud.get_node("Margin/Info/Health").text = "Health: %s / %s" % [value, character.max_health]

func _update_count():
	hud.get_node("Margin/Info/Count").text = "Collected: %s" % collected_count

func _on_collected():
	if state != RunState.PLAYING:
		return
	collected_count += 1
	_update_count()

func _on_exit_reached():
	if state != RunState.PLAYING or character.is_dead:
		return
	state = RunState.WON
	get_tree().paused = true
	win_ui.get_node("Overlay/Panel/Buttons/Count").text = "Collected: %s" % collected_count
	win_ui.show()
	win_ui.get_node("Overlay/Panel/Buttons/Retry").grab_focus()

func _on_player_died():
	if state != RunState.PLAYING:
		return
	state = RunState.DEAD
	get_tree().paused = true
	death_ui.show()
	death_ui.get_node("Overlay/Panel/Buttons/Retry").grab_focus()

func resume():
	if state != RunState.PAUSED:
		return
	pause_ui.hide()
	# Discard pre-pause requests and the controller A used to activate Resume.
	character.clear_jump_input()
	state = RunState.PLAYING
	get_tree().paused = false

func retry():
	if state not in [RunState.DEAD, RunState.PAUSED, RunState.WON]:
		return
	var previous_state = state
	state = RunState.RETRYING
	character.clear_movement_state()
	# Reload outside physics callbacks, replacing the entire run, not just the player.
	_reload_level.call_deferred(previous_state)

func _reload_level(previous_state):
	# Reload detaches this node immediately; retain the tree before that happens.
	var tree = get_tree()
	# A completion's Play Again always starts fresh. Only pause/death use entry.
	var restore_entry = arena_entered and previous_state != RunState.WON
	var restore_callback = _restore_arena.bind(tree, arena_entry_count)
	if restore_entry:
		tree.scene_changed.connect(restore_callback, CONNECT_ONE_SHOT)
	var error = tree.reload_current_scene()
	if error != OK:
		if restore_entry:
			tree.scene_changed.disconnect(restore_callback)
		state = previous_state
		push_error("Could not reload the level: %s" % error)
		return
	tree.paused = false

static func _restore_arena(tree, entry_count):
	# Static callback survives the old run being freed by the scene transition.
	var run = tree.current_scene
	run.arena_entered = true
	run.arena_entry_count = entry_count
	run.collected_count = entry_count
	run.character.position = run.get_node("ArenaSpawn").position
	run._bound_arena()
	# All gems are before the boundary. Remove even uncollected ones to prevent
	# a restored count from ever being increased by replaying the approach.
	for pickup in run.get_node("Collectibles").get_children():
		pickup.get_parent().remove_child(pickup)
		pickup.queue_free()
	run._update_count()
	# Native rendering can retain empty draw lists after replacing the paused run.
	# Refresh the restored HUD once, after scene construction has finished.
	RenderingServer.frame_post_draw.connect(run._redraw_hud, CONNECT_ONE_SHOT)
	var camera = run.character.get_node("Camera2D")
	camera.reset_smoothing()
	camera.force_update_scroll()

func _redraw_hud():
	# Let the restored controls finish their first draws before refreshing them.
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	for control in hud.find_children("*", "Control"):
		control.queue_redraw()

func main_menu():
	if state not in [RunState.DEAD, RunState.PAUSED, RunState.WON]:
		return
	var previous_state = state
	state = RunState.RETRYING
	character.clear_movement_state()
	_open_main_menu.call_deferred(previous_state)

func _open_main_menu(previous_state):
	var tree = get_tree()
	var error = tree.change_scene_to_file("res://scenes/title.tscn")
	if error != OK:
		state = previous_state
		push_error("Could not open the main menu: %s" % error)
		return
	tree.paused = false

func _quit():
	get_tree().quit()
