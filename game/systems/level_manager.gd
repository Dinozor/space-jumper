class_name LevelManager
extends Node

## Tracks player vertical progress relative to the space station and fall floor.

signal station_reached
signal left_behind

@export var station_y: float = 80.0
@export var fall_floor_y: float = -40.0
@export var player: Player

var _emitted: bool = false


func _physics_process(_delta: float) -> void:
	if player == null or _emitted:
		return
	if player.position.y >= station_y:
		_emitted = true
		station_reached.emit()
	elif player.position.y <= fall_floor_y:
		_emitted = true
		left_behind.emit()
