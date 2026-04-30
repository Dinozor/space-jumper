class_name DriftTracker
extends Node

## Monitors how far the player has drifted from the corridor centre.

signal drifted_out

const MAX_DRIFT_DISTANCE: float = 24.0

@export var player: Player

var _emitted: bool = false


func _physics_process(_delta: float) -> void:
	if player == null or _emitted:
		return
	var xz := Vector2(player.position.x, player.position.z)
	if xz.length() > MAX_DRIFT_DISTANCE:
		_emitted = true
		drifted_out.emit()
