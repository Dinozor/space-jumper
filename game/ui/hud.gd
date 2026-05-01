class_name HUD
extends CanvasLayer

## In-game HUD: score, health bar, station progress, drift warning, and start prompt.

@onready var _score_label: Label = $ScoreLabel
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _station_bar: ProgressBar = $StationBar
@onready var _jetpack_bar: ProgressBar = $JetpackBar
@onready var _drift_warning: Label = $DriftWarning
@onready var _start_prompt: Label = $StartPromptLabel
@onready var _countdown_label: Label = $CountdownLabel


func _ready() -> void:
	_health_bar.max_value = float(PlayerStats.MAX_HEALTH)


func update_score(value: int) -> void:
	_score_label.text = str(value)


func update_health(value: int) -> void:
	_health_bar.value = float(value)


func update_progress(value: float) -> void:
	_station_bar.value = value


func update_jetpack_fuel(ratio: float) -> void:
	_jetpack_bar.value = ratio


func show_jetpack_bar(show: bool) -> void:
	_jetpack_bar.visible = show


func show_drift_warning(show: bool) -> void:
	_drift_warning.visible = show


func show_start_prompt(show: bool) -> void:
	_start_prompt.visible = show


func show_countdown(value: int) -> void:
	_countdown_label.text = str(value)
	_countdown_label.visible = true


func show_countdown_go() -> void:
	_countdown_label.text = "GO!"
	_countdown_label.visible = true


func hide_countdown() -> void:
	_countdown_label.visible = false
