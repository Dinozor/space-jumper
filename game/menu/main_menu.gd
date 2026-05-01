class_name MainMenu
extends Control

## Main menu: play, level select, quit.

const _FONT: FontFile = preload("res://assets/kenney/ui/fonts/Kenney Future.ttf")

signal play_pressed
signal level_select_pressed
signal settings_pressed

@onready var _play_button: Button = $VBox/PlayButton
@onready var _level_select_button: Button = $VBox/LevelSelectButton
@onready var _settings_button: Button = $VBox/SettingsButton
@onready var _quit_button: Button = $VBox/QuitButton


func _ready() -> void:
	for btn: Button in [_play_button, _level_select_button, _settings_button, _quit_button]:
		btn.add_theme_font_override("font", _FONT)
		btn.add_theme_font_size_override("font_size", 22)
	_play_button.pressed.connect(_on_play_pressed)
	_level_select_button.pressed.connect(_on_level_select_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(get_tree().quit)


func _on_play_pressed() -> void:
	AudioManager.play_button()
	play_pressed.emit()
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_level_select_pressed() -> void:
	AudioManager.play_button()
	level_select_pressed.emit()
	get_tree().change_scene_to_file("res://game/menu/level_select.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play_button()
	settings_pressed.emit()
	get_tree().change_scene_to_file("res://game/menu/settings.tscn")
