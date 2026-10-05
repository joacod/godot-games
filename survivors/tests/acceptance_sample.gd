extends "res://tests/run_sample.gd"

# Record the real-time native viewport; inherited route uses normal content.
var evidence_dir := ""
var clip_started := false

func _initialize() -> void:
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--evidence-dir="):
            evidence_dir = argument.trim_prefix("--evidence-dir=")
    if not evidence_dir.is_absolute_path() or DirAccess.dir_exists_absolute(evidence_dir):
        push_error("Supply a new absolute --evidence-dir directory")
        quit(1)
        return
    if DirAccess.make_dir_recursive_absolute(evidence_dir.path_join("frames")) != OK:
        push_error("Cannot create evidence directory")
        quit(1)
        return
    call_deferred("_sample")

func _capture(label: String) -> void:
    await process_frame
    RenderingServer.force_draw(false)
    if root.get_texture().get_image().save_png(evidence_dir.path_join("%s.png" % label)) != OK:
        push_error("Cannot save native capture")
        quit(1)
    if label == "90s" and not clip_started:
        clip_started = true
        _record_clip()

func _record_clip() -> void:
    var started := Time.get_ticks_usec()
    var timestamps: Array[float] = []
    for index in 450:
        while Time.get_ticks_usec() < started + index * 1000000 / 30:
            await process_frame
        await process_frame
        # Custom SceneTree samples explicitly draw their viewport.
        RenderingServer.force_draw(false)
        timestamps.append((Time.get_ticks_usec() - started) / 1000000.0)
        var path := evidence_dir.path_join("frames/%04d.png" % index)
        if root.get_texture().get_image().save_png(path) != OK:
            push_error("Cannot save clip frame")
            quit(1)
            return
    var metadata := FileAccess.open(evidence_dir.path_join("clip-timestamps.json"), FileAccess.WRITE)
    if metadata == null:
        push_error("Cannot save clip timestamps")
        quit(1)
        return
    metadata.store_string(JSON.stringify(timestamps))
    print("Native clip: %d frames at 30 fps; sampled wall span %.3fs" % [timestamps.size(), timestamps.back() - timestamps.front()])
