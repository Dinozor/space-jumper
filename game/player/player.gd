class_name Player
extends CharacterBody3D

## Player controller: handles XZ movement, bounce physics, and drift tracking.

signal jumped
signal damaged(amount: int)
signal healed
signal died
signal jetpack_depleted

const MOVE_SPEED: float = 8.0
const BOUNCE_FORCE: float = 12.0
const MIN_VERTICAL_BOUNCE: float = 0.7
const LATERAL_BOUNCE_FACTOR: float = 0.5
const LATERAL_BOUNCE_DECAY: float = 8.0

@export var rotation_speed: float = 10.0
@export var max_tilt_angle: float = 0.35
@export var jetpack_duration: float = 3.0
@export var jetpack_force: float = 15.0

var stats: PlayerStats = PlayerStats.new()

var station_escape_speed: float = 10.0
var drag: float = 0.5

var input_locked: bool = false
var invincible: bool = false

var _velocity: Vector3 = Vector3.ZERO
var _lateral_bounce: Vector3 = Vector3.ZERO
var _jetpack_active: bool = false
var _jetpack_timer: float = 0.0

@onready var _mesh: Node3D = $Mesh


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	_apply_velocity(delta)
	_rotate_mesh(delta)


func start_jetpack() -> void:
	_jetpack_active = true
	_jetpack_timer = jetpack_duration


func get_jetpack_fuel_ratio() -> float:
	if not _jetpack_active:
		return 0.0
	return _jetpack_timer / jetpack_duration


func apply_boost(force: float) -> void:
	_velocity.y = force
	AudioManager.play_jump()
	jumped.emit()


func bounce(normal: Vector3) -> void:
	_velocity.y = maxf(normal.y, MIN_VERTICAL_BOUNCE) * BOUNCE_FORCE
	_lateral_bounce.x = normal.x * BOUNCE_FORCE * LATERAL_BOUNCE_FACTOR
	_lateral_bounce.z = normal.z * BOUNCE_FORCE * LATERAL_BOUNCE_FACTOR
	AudioManager.play_jump()
	jumped.emit()


func heal(amount: int) -> void:
	stats.health = mini(stats.health + amount, PlayerStats.MAX_HEALTH)
	healed.emit()


func take_damage(amount: int) -> void:
	if invincible:
		return
	stats.health -= amount
	AudioManager.play_damage()
	damaged.emit(amount)
	if stats.health <= 0:
		died.emit()


func _apply_gravity(delta: float) -> void:
	if _jetpack_active:
		_velocity.y = jetpack_force
		_jetpack_timer -= delta
		if _jetpack_timer <= 0.0:
			_jetpack_active = false
			jetpack_depleted.emit()
		return
	if _velocity.y > 0.0:
		_velocity.y *= 1.0 - drag * delta
	_velocity.y -= station_escape_speed * delta
	_velocity.y = maxf(_velocity.y, -station_escape_speed)


func _apply_movement(delta: float) -> void:
	if input_locked:
		_velocity.x = 0.0
		_velocity.z = 0.0
		return
	var input: Vector3 = Vector3(
		Input.get_axis("move_left", "move_right"), 0.0, Input.get_axis("move_forward", "move_back")
	)
	_lateral_bounce = _lateral_bounce.move_toward(Vector3.ZERO, LATERAL_BOUNCE_DECAY * delta)
	_velocity.x = input.x * MOVE_SPEED + _lateral_bounce.x
	_velocity.z = input.z * MOVE_SPEED + _lateral_bounce.z


func _apply_velocity(delta: float) -> void:
	velocity = _velocity
	move_and_slide()
	_velocity = velocity
	_handle_slide_collisions()


func _handle_slide_collisions() -> void:
	var contacted: Array[Object] = []
	for i: int in get_slide_collision_count():
		var col: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider == null or collider in contacted:
			continue
		contacted.append(collider)
		if collider.has_method("on_player_contact"):
			collider.on_player_contact(self, col.get_normal())


func _rotate_mesh(delta: float) -> void:
	var flat := Vector3(_velocity.x, 0.0, _velocity.z)
	if flat.length_squared() > 0.1:
		var target_yaw: float = atan2(flat.x, flat.z)
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_yaw, rotation_speed * delta)
	var normalized_vy: float = clamp(_velocity.y / BOUNCE_FORCE, -1.0, 1.0)
	_mesh.rotation.x = lerp(
		_mesh.rotation.x, -normalized_vy * max_tilt_angle, rotation_speed * delta
	)
