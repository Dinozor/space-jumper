class_name Game
extends Node3D

## Root node for a running level. Owns and coordinates all gameplay systems.

signal level_won
signal level_lost(reason: String)

@export var level_data: LevelData

@onready var _player: Player = $Player
@onready var _corridor_spawner: CorridorSpawner = $CorridorSpawner
@onready var _drift_tracker: DriftTracker = $DriftTracker
@onready var _level_manager: LevelManager = $LevelManager
@onready var _hud: HUD = $HUD
@onready var _game_over: GameOver = $GameOver

var _game_ended: bool = false


func _ready() -> void:
	_drift_tracker.player = _player
	_level_manager.player = _player
	_player.died.connect(_on_player_died)
	_drift_tracker.drifted_out.connect(_on_player_drifted_out)
	_level_manager.station_reached.connect(_on_station_reached)
	_level_manager.left_behind.connect(_on_player_left_behind)
	_game_over.restart_pressed.connect(_restart)
	_game_over.menu_pressed.connect(_go_to_menu)
	_game_over.hide()


func _on_player_died() -> void:
	if _game_ended:
		return
	_end_game("died")


func _on_player_drifted_out() -> void:
	if _game_ended:
		return
	_end_game("drifted")


func _on_station_reached() -> void:
	if _game_ended:
		return
	_game_ended = true
	AudioManager.play_win()
	level_won.emit()
	_game_over.show_result("won")


func _on_player_left_behind() -> void:
	if _game_ended:
		return
	_end_game("left_behind")


func _end_game(reason: String) -> void:
	_game_ended = true
	AudioManager.play_lose()
	level_lost.emit(reason)
	_game_over.show_result(reason)


func _restart() -> void:
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
