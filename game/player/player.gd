class_name Player
extends CharacterBody3D

## Player controller: handles XZ movement, bounce physics, and drift tracking.

signal jumped
signal damaged(amount: int)
signal died

const MOVE_SPEED: float = 8.0
const BOUNCE_FORCE: float = 12.0
const GRAVITY: float = -20.0

@export var rotation_speed: float = 10.0
@export var max_tilt_angle: float = 0.35

var stats: PlayerStats = PlayerStats.new()

var _velocity: Vector3 = Vector3.ZERO

@onready var _mesh: Node3D = $Mesh


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement()
	_apply_velocity(delta)
	_rotate_mesh(delta)


func bounce(normal: Vector3) -> void:
	_velocity.y = BOUNCE_FORCE
	AudioManager.play_jump()
	jumped.emit()


func take_damage(amount: int) -> void:
	stats.health -= amount
	AudioManager.play_damage()
	damaged.emit(amount)
	if stats.health <= 0:
		died.emit()


func _apply_gravity(delta: float) -> void:
	_velocity.y += GRAVITY * delta


func _apply_movement() -> void:
	var input := Vector3(
		Input.get_axis("move_left", "move_right"), 0.0, Input.get_axis("move_forward", "move_back")
	)
	_velocity.x = input.x * MOVE_SPEED
	_velocity.z = input.z * MOVE_SPEED


func _apply_velocity(delta: float) -> void:
	velocity = _velocity
	move_and_slide()
	_velocity = velocity


func _rotate_mesh(delta: float) -> void:
	var flat := Vector3(_velocity.x, 0.0, _velocity.z)
	if flat.length_squared() > 0.1:
		var target_yaw: float = atan2(flat.x, flat.z)
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_yaw, rotation_speed * delta)
	var normalized_vy: float = clamp(_velocity.y / BOUNCE_FORCE, -1.0, 1.0)
	_mesh.rotation.x = lerp(
		_mesh.rotation.x, -normalized_vy * max_tilt_angle, rotation_speed * delta
	)
