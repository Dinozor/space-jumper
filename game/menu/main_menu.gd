class_name MainMenu
extends Control

## Main menu: play, level select, scoreboard, shop, settings, quit.

signal play_pressed
signal level_select_pressed
signal settings_pressed

@onready var _play_button: Button = $VBox/PlayButton
@onready var _level_select_button: Button = $VBox/LevelSelectButton
@onready var _scoreboard_button: Button = $VBox/ScoreboardButton
@onready var _shop_button: Button = $VBox/ShopButton
@onready var _settings_button: Button = $VBox/SettingsButton
@onready var _quit_button: Button = $VBox/QuitButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_level_select_button.pressed.connect(_on_level_select_pressed)
	_scoreboard_button.pressed.connect(_on_scoreboard_pressed)
	_shop_button.pressed.connect(_on_shop_pressed)
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


func _on_scoreboard_pressed() -> void:
	AudioManager.play_button()
	GameState.scoreboard_open_level = GameState.current_level
	GameState.scoreboard_return_path = "res://game/menu/main_menu.tscn"
	get_tree().change_scene_to_file("res://game/ui/scoreboard.tscn")


func _on_shop_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/shop.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play_button()
	settings_pressed.emit()
	GameState.settings_from_main_menu = true
	get_tree().change_scene_to_file("res://game/menu/settings.tscn")
