class_name DebrisSafe
extends RigidBody3D

## Safe debris: player bounces off it without taking damage.

signal bounce_triggered(normal: Vector3)

@export var fall_speed: float = 8.0


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player and body.is_physics_processing():
		var normal := (body.global_position - global_position).normalized()
		bounce_triggered.emit(normal)
		body.bounce(normal)
