class_name CorridorSpawner
extends Node

## Spawns and recycles falling debris within the corridor.

@export var safe_debris_scene: PackedScene
@export var hazard_debris_scene: PackedScene
@export var wall_debris_scene: PackedScene
@export var doorway_debris_scene: PackedScene
@export var spawn_interval: float = 0.3
@export var spawn_z_range: float = 12.0
@export var initial_fill_count: int = 36
@export var fall_speed_min: float = 5.0
@export var fall_speed_max: float = 12.0
@export var wall_spawn_ratio: float = 0.15
@export var doorway_spawn_ratio: float = 0.05
@export var spawn_table: SpawnTable

var _timer: float = 0.0


func place_sections(sections: Array[LevelSection]) -> void:
	for section: LevelSection in sections:
		for entry: PatternEntry in section.entries:
			if entry.scene == null:
				continue
			var instance: Node3D = entry.scene.instantiate()
			add_child(instance)
			instance.position = Vector3(entry.x_offset, section.spawn_y, entry.z_offset)


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_at(80.0)


func fill_initial() -> void:
	for i: int in initial_fill_count:
		_spawn_at(randf_range(0.5, 80.0))


func _spawn_at(y: float) -> void:
	if spawn_table != null:
		_spawn_from_table(y)
	else:
		_spawn_legacy(y)


func _spawn_from_table(y: float) -> void:
	var entry: SpawnEntry = spawn_table.pick(0.0)
	if entry == null:
		return
	var instance: Node3D = entry.scene.instantiate()
	add_child(instance)
	_place_instance(instance, y, entry.is_centered)
	_configure_body(instance, _pick_speed(entry))


func _spawn_legacy(y: float) -> void:
	var scene: PackedScene = _choose_scene()
	if scene == null:
		return
	var instance: Node3D = scene.instantiate()
	add_child(instance)
	var centered: bool = scene == wall_debris_scene or scene == doorway_debris_scene
	_place_instance(instance, y, centered)
	_configure_body(instance, randf_range(fall_speed_min, fall_speed_max))


func _configure_body(instance: Node3D, speed: float) -> void:
	var body := instance as RigidBody3D
	body.gravity_scale = 0.0
	body.linear_velocity = Vector3(0.0, -speed, 0.0)


func _pick_speed(entry: SpawnEntry) -> float:
	if entry.fall_speed_override > 0.0:
		return randf_range(entry.fall_speed_override * 0.75, entry.fall_speed_override * 1.25)
	return randf_range(fall_speed_min, fall_speed_max)


func _choose_scene() -> PackedScene:
	var roll: float = randf()
	if wall_debris_scene != null and roll < wall_spawn_ratio:
		return wall_debris_scene
	if doorway_debris_scene != null and roll < wall_spawn_ratio + doorway_spawn_ratio:
		return doorway_debris_scene
	return safe_debris_scene if randf() > 0.25 else hazard_debris_scene


func _place_instance(instance: Node3D, y: float, centered: bool) -> void:
	if centered:
		instance.position = Vector3(0.0, y, 0.0)
	else:
		instance.position = Vector3(
			randf_range(-spawn_z_range, spawn_z_range),
			y,
			randf_range(-spawn_z_range, spawn_z_range),
		)
