class_name MainMenu
extends Control

## Main menu: play, level select, quit.

signal play_pressed
signal level_select_pressed

@onready var _play_button: Button = $VBox/PlayButton
@onready var _level_select_button: Button = $VBox/LevelSelectButton
@onready var _quit_button: Button = $VBox/QuitButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_level_select_button.pressed.connect(_on_level_select_pressed)
	_quit_button.pressed.connect(get_tree().quit)


func _on_play_pressed() -> void:
	play_pressed.emit()
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_level_select_pressed() -> void:
	level_select_pressed.emit()
	get_tree().change_scene_to_file("res://game/menu/level_select.tscn")
