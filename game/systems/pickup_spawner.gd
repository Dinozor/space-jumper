class_name PickupSpawner
extends Node

## Drops health pickups above the player on a timer.

@export var pickup_scene: PackedScene
@export var spawn_interval: float = 15.0
@export var spawn_z_range: float = 10.0
@export var spawn_height_above_player: float = 40.0

var player: Player

var _timer: float = 0.0


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn()


func _spawn() -> void:
	if pickup_scene == null or player == null:
		return
	var instance: Node3D = pickup_scene.instantiate()
	add_child(instance)
	instance.position = Vector3(
		randf_range(-spawn_z_range, spawn_z_range),
		player.position.y + spawn_height_above_player,
		randf_range(-spawn_z_range, spawn_z_range),
	)
