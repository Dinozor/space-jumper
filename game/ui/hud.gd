class_name HUD
extends CanvasLayer

## In-game HUD: score, health bar, station progress, drift warning, and start prompt.

const _FONT: FontFile = preload("res://assets/kenney/ui/fonts/Kenney Future.ttf")

@onready var _score_label: Label = $ScoreLabel
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _station_bar: ProgressBar = $StationBar
@onready var _jetpack_bar: ProgressBar = $JetpackBar
@onready var _drift_warning: Label = $DriftWarning
@onready var _start_prompt: Label = $StartPromptLabel
@onready var _countdown_label: Label = $CountdownLabel


func _ready() -> void:
	_score_label.add_theme_font_override("font", _FONT)
	_score_label.add_theme_font_size_override("font_size", 28)
	_drift_warning.add_theme_font_override("font", _FONT)
	_drift_warning.add_theme_font_size_override("font_size", 20)
	_drift_warning.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 1.0))
	_start_prompt.add_theme_font_override("font", _FONT)
	_start_prompt.add_theme_font_size_override("font_size", 34)
	_start_prompt.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
	_countdown_label.add_theme_font_override("font", _FONT)
	_countdown_label.add_theme_font_size_override("font_size", 96)
	_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	_health_bar.max_value = float(PlayerStats.MAX_HEALTH)
	_style_bar(_health_bar, Color(0.85, 0.2, 0.1, 1.0))
	_style_bar(_station_bar, Color(0.1, 0.65, 0.9, 1.0))
	_style_bar(_jetpack_bar, Color(1.0, 0.7, 0.0, 1.0))


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


func _style_bar(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bar.add_theme_stylebox_override("background", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("fill", fill)
