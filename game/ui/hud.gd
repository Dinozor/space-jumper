class_name HUD
extends CanvasLayer

## In-game HUD: score, health, drift warning.

const _FONT: FontFile = preload("res://assets/kenney/ui/fonts/Kenney Future.ttf")

@onready var _score_label: Label = $ScoreLabel
@onready var _health_label: Label = $HealthLabel
@onready var _drift_warning: Label = $DriftWarning


func _ready() -> void:
	_score_label.add_theme_font_override("font", _FONT)
	_score_label.add_theme_font_size_override("font_size", 28)
	_health_label.add_theme_font_override("font", _FONT)
	_health_label.add_theme_font_size_override("font_size", 28)
	_drift_warning.add_theme_font_override("font", _FONT)
	_drift_warning.add_theme_font_size_override("font_size", 20)
	_drift_warning.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 1.0))


func update_score(value: int) -> void:
	_score_label.text = str(value)


func update_health(value: int) -> void:
	_health_label.text = "x%d" % value


func show_drift_warning(visible: bool) -> void:
	_drift_warning.visible = visible
