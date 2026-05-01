class_name Game
extends Node3D

## Root node for a running level. Owns and coordinates all gameplay systems.

signal level_won
signal level_lost(reason: EndState)

enum EndState { DIED, DRIFTED, LEFT_BEHIND, WON }

const INTRO_START_Y: float = -25.0
const CABLE_GRAB_DISTANCE: float = 15.0
const CABLE_PULL_DURATION: float = 1.8

@export var level_data: LevelData

@onready var _player: Player = $Player
@onready var _corridor_spawner: CorridorSpawner = $CorridorSpawner
@onready var _pickup_spawner: PickupSpawner = $PickupSpawner
@onready var _drift_tracker: DriftTracker = $DriftTracker
@onready var _level_manager: LevelManager = $LevelManager
@onready var _hud: HUD = $HUD
@onready var _game_over: GameOver = $GameOver

var _intro_active: bool = false
var _game_started: bool = false
var _game_ended: bool = false
var _has_cable_ending: bool = false
var _cable_grabbed: bool = false


func _ready() -> void:
	_load_level_data()
	_apply_level_data()
	_drift_tracker.player = _player
	_level_manager.player = _player
	_pickup_spawner.player = _player
	_player.died.connect(_on_player_died)
	_player.damaged.connect(_on_player_damaged)
	_player.healed.connect(_on_player_healed)
	_player.jetpack_depleted.connect(_on_jetpack_depleted)
	_drift_tracker.drifted_out.connect(_on_player_drifted_out)
	_level_manager.station_reached.connect(_on_station_reached)
	_level_manager.left_behind.connect(_on_player_left_behind)
	_game_over.restart_pressed.connect(_restart)
	_game_over.menu_pressed.connect(_go_to_menu)
	_game_over.hide()
	_corridor_spawner.fill_initial()
	_hud.update_health(_player.stats.health)
	_begin_intro()


func _process(_delta: float) -> void:
	var total: float = _level_manager.station_y - _level_manager.fall_floor_y
	var progress: float = clamp(
		(_player.position.y - _level_manager.fall_floor_y) / total, 0.0, 1.0
	)
	_hud.update_progress(progress)
	if _intro_active:
		var digit: int = ceili(
			_player.get_jetpack_fuel_ratio() * float(roundi(_player.jetpack_duration))
		)
		_hud.show_countdown(maxi(digit, 1))
	elif _has_cable_ending and _game_started and not _cable_grabbed and not _game_ended:
		if _player.position.y >= _level_manager.station_y - CABLE_GRAB_DISTANCE:
			_start_cable_cinematic()


func _load_level_data() -> void:
	if level_data != null:
		return
	for level: LevelData in GameState.levels:
		if level.level_id == GameState.current_level:
			level_data = level
			return


func _apply_level_data() -> void:
	if level_data == null:
		return
	_corridor_spawner.spawn_z_range = level_data.corridor_radius
	_corridor_spawner.fall_speed_min = level_data.station_escape_speed * 0.75
	_corridor_spawner.fall_speed_max = level_data.station_escape_speed * 1.25
	_corridor_spawner.place_sections(level_data.sections)
	_has_cable_ending = level_data.has_cable_ending
	if _has_cable_ending:
		_spawn_cable()


func _begin_intro() -> void:
	_player.position.y = INTRO_START_Y
	_player.input_locked = true
	_player.invincible = true
	_player.set_physics_process(true)
	_player.start_jetpack()
	_intro_active = true
	_hud.show_countdown(roundi(_player.jetpack_duration))


func _on_jetpack_depleted() -> void:
	if not _intro_active:
		return
	_intro_active = false
	_game_started = true
	_player.input_locked = false
	_player.invincible = false
	_hud.show_countdown_go()
	get_tree().create_timer(0.5).timeout.connect(_hud.hide_countdown)


func _spawn_cable() -> void:
	var cable := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.15
	mesh.bottom_radius = 0.15
	mesh.height = CABLE_GRAB_DISTANCE
	cable.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.65, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.3, 0.05)
	mat.emission_energy_multiplier = 1.5
	cable.material_override = mat
	cable.position = Vector3(0.0, _level_manager.station_y - CABLE_GRAB_DISTANCE * 0.5, 0.0)
	add_child(cable)


func _start_cable_cinematic() -> void:
	_cable_grabbed = true
	_game_ended = true
	_player.set_physics_process(false)
	_player.invincible = true
	var tween: Tween = create_tween()
	tween.tween_property(_player, "position:y", _level_manager.station_y, CABLE_PULL_DURATION)
	tween.tween_callback(_finish_cable_win)


func _finish_cable_win() -> void:
	AudioManager.play_win()
	level_won.emit()
	_game_over.show_result(EndState.WON)


func _on_player_healed() -> void:
	_hud.update_health(_player.stats.health)


func _on_player_damaged(_amount: int) -> void:
	_hud.update_health(_player.stats.health)


func _on_player_died() -> void:
	if _game_ended:
		return
	_end_game(EndState.DIED)


func _on_player_drifted_out() -> void:
	if _game_ended:
		return
	_end_game(EndState.DRIFTED)


func _on_station_reached() -> void:
	if _game_ended:
		return
	_game_ended = true
	AudioManager.play_win()
	level_won.emit()
	_game_over.show_result(EndState.WON)


func _on_player_left_behind() -> void:
	if _game_ended:
		return
	_end_game(EndState.LEFT_BEHIND)


func _end_game(reason: EndState) -> void:
	_game_ended = true
	AudioManager.play_lose()
	level_lost.emit(reason)
	_game_over.show_result(reason)


func _restart() -> void:
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
