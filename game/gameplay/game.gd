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

var _game_started: bool = false
var _game_ended: bool = false


func _ready() -> void:
	_drift_tracker.player = _player
	_level_manager.player = _player
	_player.died.connect(_on_player_died)
	_player.damaged.connect(_on_player_damaged)
	_player.jetpack_depleted.connect(_on_jetpack_depleted)
	_drift_tracker.drifted_out.connect(_on_player_drifted_out)
	_level_manager.station_reached.connect(_on_station_reached)
	_level_manager.left_behind.connect(_on_player_left_behind)
	_game_over.restart_pressed.connect(_restart)
	_game_over.menu_pressed.connect(_go_to_menu)
	_game_over.hide()
	_corridor_spawner.fill_initial()
	_player.set_physics_process(false)
	_hud.show_start_prompt(true)
	_hud.update_health(_player.stats.health)


func _process(_delta: float) -> void:
	var total: float = _level_manager.station_y - _level_manager.fall_floor_y
	var progress: float = clamp(
		(_player.position.y - _level_manager.fall_floor_y) / total, 0.0, 1.0
	)
	_hud.update_progress(progress)
	if _game_started:
		_hud.update_jetpack_fuel(_player.get_jetpack_fuel_ratio())


func _unhandled_input(event: InputEvent) -> void:
	if _game_started or _game_ended:
		return
	var is_press: bool = (
		(event is InputEventKey and event.is_pressed() and not event.is_echo())
		or (event is InputEventMouseButton and event.is_pressed())
		or (event is InputEventJoypadButton and event.is_pressed())
	)
	if is_press:
		_start_game()


func _start_game() -> void:
	_game_started = true
	_player.set_physics_process(true)
	_player.start_jetpack()
	_hud.show_start_prompt(false)
	_hud.show_jetpack_bar(true)


func _on_jetpack_depleted() -> void:
	_hud.show_jetpack_bar(false)


func _on_player_damaged(_amount: int) -> void:
	_hud.update_health(_player.stats.health)


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
