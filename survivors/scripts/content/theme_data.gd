class_name SurvivorThemeData
extends Resource

@export var title: String = "Last Light Clearing"
@export var start_label: String = "Start"
@export var return_label: String = "Back to menu"
@export var victory_label: String = "The clearing holds"
@export var defeat_label: String = "The light fades"
@export var pause_label: String = "Paused"
@export var resume_label: String = "Resume"
@export var retry_label: String = "Retry"
@export var foundation_label: String = "STEP 01 / ARENA FOUNDATION"
@export var foundation_note: String = "Static markers. Movement begins in Step 02."
@export var background_color: Color = Color("101b23")
@export var floor_color: Color = Color("233c3b")
@export var boundary_color: Color = Color("718f76")
@export var player_color: Color = Color("f9d884")
@export var enemy_color: Color = Color("e68571")
@export_file("*.tscn") var arena_visual_scene: String
@export var ui_theme: Theme
@export var music: AudioStream
