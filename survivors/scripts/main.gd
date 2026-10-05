extends Node

const Validator = preload("res://scripts/content/content_validator.gd")
const RUN_SCENE = preload("res://scenes/run.tscn")

@export var content: SurvivorRunData = preload("res://data/run.tres")
@export var presentation: SurvivorThemeData = preload("res://data/theme.tres")
var run: Node2D

@onready var menu: ColorRect = $UI/Root/Menu
@onready var column: VBoxContainer = $UI/Root/Menu/Center/Column
@onready var arena_ui: Control = $UI/Root/ArenaUI

func _ready() -> void:
    column.get_node("Start").pressed.connect(start_run)
    arena_ui.get_node("Footer/Back").pressed.connect(return_to_menu)
    column.get_node("Start").grab_focus()
    if presentation == null:
        column.get_node("Error").text = "Cannot start: theme Resource is missing."
        column.get_node("Error").show()
        return
    $UI/Root.theme = presentation.ui_theme
    RenderingServer.set_default_clear_color(presentation.background_color)
    menu.color = presentation.background_color
    column.get_node("Eyebrow").text = presentation.foundation_label
    column.get_node("Title").text = presentation.title
    column.get_node("Note").text = presentation.foundation_note
    column.get_node("Start").text = presentation.start_label
    arena_ui.get_node("Header").text = presentation.foundation_label
    arena_ui.get_node("Footer/Note").text = presentation.foundation_note
    arena_ui.get_node("Footer/Back").text = presentation.return_label

func start_run() -> bool:
    if is_instance_valid(run):
        return false
    var errors := Validator.validate(content, presentation)
    if not errors.is_empty():
        column.get_node("Error").text = "Cannot start:\n" + "\n".join(errors)
        column.get_node("Error").show()
        return false
    column.get_node("Error").hide()
    run = RUN_SCENE.instantiate()
    run.content = content
    run.presentation = presentation
    add_child(run)
    menu.hide()
    arena_ui.show()
    arena_ui.get_node("Footer/Back").grab_focus()
    return true

func return_to_menu() -> void:
    if is_instance_valid(run):
        remove_child(run)
        run.queue_free()
    run = null
    arena_ui.hide()
    menu.show()
    column.get_node("Start").grab_focus()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel") and is_instance_valid(run):
        return_to_menu()
        get_viewport().set_input_as_handled()
