extends Control

var weapons: Array[SurvivorWeaponData] = []
var labels: Array[Label] = []

func _ready() -> void:
    for index in 4:
        var label := Label.new()
        label.position = Vector2(42 + index * 150, 54)
        label.add_theme_font_size_override("font_size", 13)
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(label)
        labels.append(label)

func set_loadout(names: PackedStringArray, equipped: Array[SurvivorWeaponData]) -> void:
    weapons = equipped.duplicate()
    for index in 4:
        labels[index].text = names[index] if index < names.size() else ""
    queue_redraw()

func _draw() -> void:
    for index in weapons.size():
        var at := Vector2(28 + index * 150, 64)
        var tint := Color("f9d884")
        match weapons[index].behavior:
            SurvivorWeaponData.Behavior.NEAREST_SHOT:
                draw_colored_polygon(PackedVector2Array([at + Vector2(0, -9), at + Vector2(6, 0), at + Vector2(0, 9), at + Vector2(-6, 0)]), tint)
            SurvivorWeaponData.Behavior.ORBIT:
                draw_arc(at, 8, 0, TAU, 20, tint, 2)
                draw_circle(at + Vector2(8, 0), 3, tint)
            SurvivorWeaponData.Behavior.PULSE:
                draw_arc(at, 8, 0, TAU, 20, Color("82d8cb"), 2)
                draw_circle(at, 3, Color("82d8cb"))
            SurvivorWeaponData.Behavior.CARDINAL_BURST:
                draw_line(at - Vector2(8, 0), at + Vector2(8, 0), Color("e68571"), 3)
                draw_line(at - Vector2(0, 8), at + Vector2(0, 8), Color("e68571"), 3)
