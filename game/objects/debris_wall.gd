class_name DebrisWall
extends RigidBody3D

## Wall-type obstacle: blocks one half of the corridor, forcing the player to find the open side.

@export var fall_speed: float = 8.0
@export var damage: int = 1

const WALL_HALF_OFFSET: float = 5.0

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _mesh_node: MeshInstance3D = $Mesh


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)
	body_entered.connect(_on_body_entered)
	var side: float = 1.0 if randf() > 0.5 else -1.0
	_collision.position.x = side * WALL_HALF_OFFSET
	_mesh_node.position.x = side * WALL_HALF_OFFSET


func _on_body_entered(body: Node3D) -> void:
	if body is Player and body.is_physics_processing():
		body.take_damage(damage)
		var normal := (body.global_position - global_position).normalized()
		body.bounce(normal)
