class_name CorridorSpawner
extends Node

## Spawns and recycles falling debris within the corridor.

@export var safe_debris_scene: PackedScene
@export var hazard_debris_scene: PackedScene
@export var spawn_interval: float = 0.8
@export var spawn_z_range: float = 6.0

var _timer: float = 0.0


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_debris()


func _spawn_debris() -> void:
	var scene: PackedScene = safe_debris_scene if randf() > 0.25 else hazard_debris_scene
	if scene == null:
		return
	var instance: Node3D = scene.instantiate()
	add_child(instance)
	instance.position = Vector3(
		randf_range(-spawn_z_range, spawn_z_range),
		20.0,
		randf_range(-spawn_z_range, spawn_z_range)
	)
