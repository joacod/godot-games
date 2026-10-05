extends Node2D

# The run advances this schedule only after damage has resolved for the tick.
var run: Node2D
var next_spawn := 1.0
var elite_spawned := false
var pending: Array[Dictionary] = []
var spawned_ordinary := 0
var spawned_elite := 0
var rng := RandomNumberGenerator.new()

func configure(owner_run: Node2D) -> void:
    run = owner_run
    next_spawn = run.content.spawn_phases[0].interval
    rng.randomize()

func interval_at(seconds: float) -> float:
    var interval: float = run.content.spawn_phases[0].interval
    for phase in run.content.spawn_phases:
        if seconds >= phase.start_seconds:
            interval = phase.interval
    return interval

func ordinary_count() -> int:
    var count := 0
    for enemy in run.get_node("Enemies").get_children():
        if enemy.is_alive() and not enemy.content.elite:
            count += 1
    for entry in pending:
        if not entry.elite:
            count += 1
    return count

func advance(seconds: float, delta: float) -> void:
    if run.ended or get_tree().paused:
        return
    for index in range(pending.size() - 1, -1, -1):
        pending[index].delay -= delta
        if pending[index].delay <= 0:
            if not pending[index].get("spawned", false):
                _spawn(pending[index].at, pending[index].elite)
            pending.remove_at(index)
    if seconds >= run.content.elite_spawn_seconds and not elite_spawned:
        elite_spawned = true
        _request(true)
    while next_spawn <= seconds + 0.00001:
        if ordinary_count() < run.content.ordinary_cap:
            _request(false)
        var interval := interval_at(next_spawn)
        var following := next_spawn + interval
        # Phase transitions start a new cadence exactly at their boundary.
        for phase in run.content.spawn_phases:
            if phase.start_seconds > next_spawn and phase.start_seconds < following:
                following = phase.start_seconds
        next_spawn = following
    queue_redraw()

func entry_position() -> Dictionary:
    var size: Vector2 = run.content.arena_size
    var player: Node2D = run.get_node("Player")
    var camera: Camera2D = player.get_node("Camera2D")
    camera.force_update_scroll()
    var view_size := get_viewport_rect().size / camera.zoom
    var visible_rect := Rect2(camera.get_screen_center_position() - view_size / 2, view_size).grow(28)
    var candidates: Array[Vector2] = []
    for step in range(1, 10):
        var fraction := step / 10.0
        candidates.append(Vector2(24, lerpf(24, size.y - 24, fraction)))
        candidates.append(Vector2(size.x - 24, lerpf(24, size.y - 24, fraction)))
        candidates.append(Vector2(lerpf(24, size.x - 24, fraction), 24))
        candidates.append(Vector2(lerpf(24, size.x - 24, fraction), size.y - 24))
    var offscreen: Array[Vector2] = []
    var farthest := candidates[0]
    for at in candidates:
        if at.distance_squared_to(player.position) > farthest.distance_squared_to(player.position):
            farthest = at
        if at.distance_to(player.position) >= 160 and not visible_rect.has_point(at):
            offscreen.append(at)
    if not offscreen.is_empty():
        return {"at": offscreen[rng.randi_range(0, offscreen.size() - 1)], "marked": false}
    return {"at": farthest, "marked": true}

func _request(elite: bool) -> void:
    var entry := entry_position()
    if entry.marked:
        var warning := {"at": entry.at, "elite": elite, "delay": 0.7}
        if elite:
            # Appear at the exact elite deadline, but make the marked entry
            # harmless until its warning ends when no offscreen edge exists.
            var enemy: CharacterBody2D = run.spawn_enemy(entry.at, run.content.enemies[1])
            enemy.entry_delay = 0.7
            enemy.collision_layer = 0
            enemy.get_node("Health").active = false
            spawned_elite += 1
            warning["spawned"] = true
        pending.append(warning)
    else:
        _spawn(entry.at, elite)

func _spawn(at: Vector2, elite: bool) -> void:
    if run.ended:
        return
    run.spawn_enemy(at, run.content.enemies[1 if elite else 0])
    if elite:
        spawned_elite += 1
    else:
        spawned_ordinary += 1

func stop() -> void:
    pending.clear()
    queue_redraw()

func _draw() -> void:
    for entry in pending:
        draw_arc(entry.at, 20, 0, TAU, 24, Color("f9d884"), 3)
        draw_line(entry.at - Vector2(12, 0), entry.at + Vector2(12, 0), Color("f9d884"), 2)
        draw_line(entry.at - Vector2(0, 12), entry.at + Vector2(0, 12), Color("f9d884"), 2)
