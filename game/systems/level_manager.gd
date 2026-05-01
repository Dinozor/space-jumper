class_name LevelManager
extends Node

## Tracks player vertical progress relative to the space station using distance checks.

signal station_reached
signal left_behind

@export var station_y: float = 80.0
## Distance above the player at which the station is considered reached.
@export var station_reach_distance: float = 5.0
## Distance below the station at which the player is considered left behind.
@export var left_behind_distance: float = 120.0
@export var player: Player


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var distance: float = station_y - player.position.y
	if distance <= station_reach_distance:
		set_physics_process(false)
		station_reached.emit()
	elif distance >= left_behind_distance:
		set_physics_process(false)
		left_behind.emit()
