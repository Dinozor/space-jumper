class_name CorridorSpawner
extends Node

## Spawns and recycles falling debris within the corridor.

@export var safe_debris_scene: PackedScene
@export var hazard_debris_scene: PackedScene
@export var spawn_interval: float = 0.8
@export var spawn_z_range: float = 6.0
@export var initial_fill_count: int = 18

var _timer: float = 0.0


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_at(20.0)


func fill_initial() -> void:
	for i: int in initial_fill_count:
		_spawn_at(randf_range(0.5, 20.0))


func _spawn_at(y: float) -> void:
	var scene: PackedScene = safe_debris_scene if randf() > 0.25 else hazard_debris_scene
	if scene == null:
		return
	var instance: Node3D = scene.instantiate()
	add_child(instance)
	instance.position = Vector3(
		randf_range(-spawn_z_range, spawn_z_range), y, randf_range(-spawn_z_range, spawn_z_range)
	)
