class_name Player
extends CharacterBody3D

## Player controller: handles XZ movement, bounce physics, and drift tracking.

signal jumped
signal damaged(amount: int)
signal died

const MOVE_SPEED: float = 8.0
const BOUNCE_FORCE: float = 12.0
const GRAVITY: float = -20.0

var stats: PlayerStats = PlayerStats.new()

var _velocity: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement()
	_apply_velocity(delta)


func bounce(normal: Vector3) -> void:
	_velocity.y = BOUNCE_FORCE
	jumped.emit()


func take_damage(amount: int) -> void:
	stats.health -= amount
	damaged.emit(amount)
	if stats.health <= 0:
		died.emit()


func _apply_gravity(delta: float) -> void:
	_velocity.y += GRAVITY * delta


func _apply_movement() -> void:
	var input := Vector3(
		Input.get_axis("move_left", "move_right"),
		0.0,
		Input.get_axis("move_forward", "move_back")
	)
	_velocity.x = input.x * MOVE_SPEED
	_velocity.z = input.z * MOVE_SPEED


func _apply_velocity(delta: float) -> void:
	velocity = _velocity
	move_and_slide()
	_velocity = velocity
