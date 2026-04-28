class_name HUD
extends CanvasLayer

## In-game HUD: score, health, drift warning.

@onready var _score_label: Label = $ScoreLabel
@onready var _health_label: Label = $HealthLabel
@onready var _drift_warning: Label = $DriftWarning


func update_score(value: int) -> void:
	_score_label.text = str(value)


func update_health(value: int) -> void:
	_health_label.text = "x%d" % value


func show_drift_warning(visible: bool) -> void:
	_drift_warning.visible = visible
