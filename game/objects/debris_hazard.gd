class_name DebrisHazard
extends RigidBody3D

## Hazard debris: damages the player on contact but still allows a bounce.

@export var fall_speed: float = 8.0
@export var damage: int = 1


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.take_damage(damage)
		var normal := (body.global_position - global_position).normalized()
		body.bounce(normal)
