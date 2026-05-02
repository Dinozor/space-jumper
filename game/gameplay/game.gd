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
@onready var _win_screen: WinScreen = $WinScreen
@onready var _lose_screen: LoseScreen = $LoseScreen
@onready var _pause_menu: PauseMenu = $PauseMenu

var _intro_active: bool = false
var _game_started: bool = false
var _game_ended: bool = false
var _has_cable_ending: bool = false
var _cable_grabbed: bool = false
var _game_start_time: float = 0.0


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
	if GameState.last_attempt_level_id != GameState.current_level:
		GameState.attempt_count = 0
		GameState.last_attempt_level_id = GameState.current_level
	GameState.attempt_count += 1
	_win_screen.play_again_pressed.connect(_restart)
	_win_screen.next_level_pressed.connect(_go_to_next_level)
	_win_screen.shop_pressed.connect(_go_to_shop)
	_win_screen.menu_pressed.connect(_go_to_menu)
	_lose_screen.retry_pressed.connect(_restart)
	_lose_screen.menu_pressed.connect(_go_to_menu)
	_win_screen.hide()
	_lose_screen.hide()
	_corridor_spawner.fill_initial()
	_hud.update_health(_player.stats.health)
	_begin_intro()


func _unhandled_input(_event: InputEvent) -> void:
	if not Input.is_action_just_pressed(&"ui_cancel"):
		return
	if not _game_started or _game_ended:
		return
	get_viewport().set_input_as_handled()
	get_tree().paused = true
	_pause_menu.show()


func _process(_delta: float) -> void:
	var distance: float = _level_manager.station_y - _player.position.y
	var progress: float = clamp(1.0 - distance / _level_manager.left_behind_distance, 0.0, 1.0)
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
	_player.station_escape_speed = level_data.station_escape_speed
	_player.drag = level_data.drag
	_corridor_spawner.spawn_z_range = level_data.corridor_radius
	_corridor_spawner.fall_speed_min = level_data.station_escape_speed * 0.75
	_corridor_spawner.fall_speed_max = level_data.station_escape_speed * 1.25
	_corridor_spawner.place_sections(level_data.sections)
	if level_data.spawn_table != null:
		_corridor_spawner.spawn_table = level_data.spawn_table
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
	_game_start_time = Time.get_unix_time_from_system()
	_player.input_locked = false
	_player.invincible = false
	_hud.show_countdown_go()
	get_tree().create_timer(0.5).timeout.connect(_hud.hide_countdown)


func _record_attempt(result: String) -> void:
	if not _game_started:
		return
	var now: float = Time.get_unix_time_from_system()
	var elapsed: float = now - _game_start_time
	var ts: int = int(now)
	var key: String = str(GameState.current_level)
	if key not in GameState.scoreboard:
		GameState.scoreboard[key] = []
	var entries: Array = GameState.scoreboard[key]
	entries.append({"result": result, "time": elapsed, "ts": ts})
	if entries.size() > SaveManager.MAX_SCORES_PER_LEVEL:
		var oldest_idx: int = 0
		var oldest_ts: int = int(entries[0]["ts"])
		for i: int in range(1, entries.size()):
			var candidate: int = int(entries[i]["ts"])
			if candidate < oldest_ts:
				oldest_ts = candidate
				oldest_idx = i
		entries.remove_at(oldest_idx)
	SaveManager.save_scores()


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
	_record_attempt(EndState.keys()[EndState.WON])
	_award_currency()
	AudioManager.play_win()
	level_won.emit()
	_win_screen.show_result(
		level_data.level_reward if level_data != null else 0, GameState.currency
	)


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
	_record_attempt(EndState.keys()[EndState.WON])
	_award_currency()
	AudioManager.play_win()
	level_won.emit()
	_win_screen.show_result(
		level_data.level_reward if level_data != null else 0, GameState.currency
	)


func _award_currency() -> void:
	if level_data != null:
		GameState.currency += level_data.level_reward
		GameState.unlock_next_level(level_data.level_id)
		SaveManager.save_progression()


func _on_player_left_behind() -> void:
	if _game_ended:
		return
	_end_game(EndState.LEFT_BEHIND)


func _end_game(reason: EndState) -> void:
	_game_ended = true
	_record_attempt(EndState.keys()[reason])
	AudioManager.play_lose()
	level_lost.emit(reason)
	_lose_screen.show_result(reason, GameState.attempt_count)


func _restart() -> void:
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	GameState.last_attempt_level_id = -1
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _go_to_next_level() -> void:
	GameState.current_level += 1
	get_tree().reload_current_scene()


func _go_to_shop() -> void:
	GameState.last_attempt_level_id = -1
	get_tree().change_scene_to_file("res://game/menu/shop.tscn")
