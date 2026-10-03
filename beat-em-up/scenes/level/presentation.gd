extends Node2D
## Local sparks and event cues only. Damage, decisions and timings stay with actors.

signal sound_requested(cue: StringName)

@onready var actors: Node2D = get_parent().get_node("Actors")
var impacts: Array[Dictionary] = []


func _ready() -> void:
	actors.child_entered_tree.connect(_watch)
	for actor in actors.get_children():
		_watch(actor)


func _watch(actor: Node) -> void:
	if not actor.is_node_ready():
		actor.ready.connect(_watch.bind(actor), CONNECT_ONE_SHOT)
		return
	if actor.has_node("Anchor"):
		actor.get_node("Anchor").hide()
	if actor.has_signal("attack_started"):
		actor.attack_started.connect(func() -> void: sound_requested.emit(&"swing"))
	if actor.has_signal("damaged"):
		actor.damaged.connect(_impact.bind(actor))
	if actor.has_signal("collected"):
		actor.collected.connect(_pickup.bind(actor))


func _impact(actor: Node2D) -> void:
	var cue: StringName = &"hit"
	var color := Color(1.0, 0.85, 0.45)
	var height := 38.0
	if actor == get_parent().player:
		cue = &"hurt"
		color = Color(1.0, 0.45, 0.3)
	elif actor.has_signal("broken") and actor.is_broken:
		cue = &"break"
	if actor is CharacterBody2D:
		height += actor.jump_height
	impacts.append({"position": actor.position - Vector2(0, height), "time": 0.0, "color": color})
	sound_requested.emit(cue)
	queue_redraw()


func _pickup(actor: Node2D) -> void:
	impacts.append({"position": actor.position - Vector2(0, 20), "time": 0.0,
		"color": Color(0.45, 1.0, 0.75)})
	sound_requested.emit(&"pickup")
	queue_redraw()


func _process(delta: float) -> void:
	if impacts.is_empty():
		return
	for index in range(impacts.size() - 1, -1, -1):
		impacts[index].time += delta
		if impacts[index].time >= 0.18:
			impacts.remove_at(index)
	queue_redraw()


func _draw() -> void:
	for impact in impacts:
		var progress: float = impact.time / 0.18
		var color: Color = impact.color
		color.a = 1.0 - progress
		for index in range(8):
			var direction := Vector2.RIGHT.rotated(index * TAU / 8.0)
			draw_line(impact.position + direction * (2.0 + progress * 8.0),
				impact.position + direction * (9.0 + progress * 12.0), color, 2.0)
