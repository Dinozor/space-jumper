class_name DebrisWall
extends RigidBody3D

## Wall-type obstacle: blocks one half of the corridor, forcing the player to find the open side.

const WALL_HALF_OFFSET: float = 5.0
const BOUNCE_COOLDOWN: float = 0.5

@export var fall_speed: float = 8.0
@export var damage: int = 1

var _bounce_on_cooldown: bool = false

@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _mesh_node: MeshInstance3D = $Mesh


func _ready() -> void:
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)
	var side: float = 1.0 if randf() > 0.5 else -1.0
	_collision.position.x = side * WALL_HALF_OFFSET
	_mesh_node.position.x = side * WALL_HALF_OFFSET


## Called by the player when a slide collision is detected against this object.
func on_player_contact(player: Player, normal: Vector3) -> void:
	if _bounce_on_cooldown:
		return
	_bounce_on_cooldown = true
	get_tree().create_timer(BOUNCE_COOLDOWN).timeout.connect(_clear_bounce_cooldown)
	player.bounce(normal)


func _clear_bounce_cooldown() -> void:
	_bounce_on_cooldown = false
