class_name DebrisDoorway
extends RigidBody3D

## Huge space-station chunk with a doorway gap; player must navigate through the opening.

const CORRIDOR_HALF: float = 12.0
const DOOR_WIDTH: float = 8.0
const SLAB_HEIGHT: float = 20.0
const SLAB_DEPTH: float = 6.0
const BOUNCE_COOLDOWN: float = 0.5

@export var fall_speed: float = 8.0
@export var damage: int = 1

var _bounce_on_cooldown: bool = false

@onready var _left_col: CollisionShape3D = $LeftCollision
@onready var _right_col: CollisionShape3D = $RightCollision
@onready var _left_mesh: MeshInstance3D = $LeftMesh
@onready var _right_mesh: MeshInstance3D = $RightMesh


func _ready() -> void:
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)
	var offsets: Array[float] = [-4.0, 0.0, 4.0]
	var door_x: float = offsets[randi() % offsets.size()]
	var mat: StandardMaterial3D = _make_material()
	_configure_slab(_left_col, _left_mesh, door_x, true, mat)
	_configure_slab(_right_col, _right_mesh, door_x, false, mat)


func _configure_slab(
	col: CollisionShape3D,
	mesh: MeshInstance3D,
	door_x: float,
	is_left: bool,
	mat: StandardMaterial3D,
) -> void:
	var far_x: float = -CORRIDOR_HALF if is_left else CORRIDOR_HALF
	var near_x: float = door_x + (-DOOR_WIDTH / 2.0 if is_left else DOOR_WIDTH / 2.0)
	var width: float = absf(near_x - far_x)
	var center_x: float = (far_x + near_x) / 2.0
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(width, SLAB_HEIGHT, SLAB_DEPTH)
	col.shape = box
	col.position.x = center_x
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(width, SLAB_HEIGHT, SLAB_DEPTH)
	mesh.mesh = box_mesh
	mesh.position.x = center_x
	mesh.material_override = mat


func _make_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.32, 0.38, 1.0)
	mat.metallic = 0.7
	mat.roughness = 0.4
	return mat


## Called by the player when a slide collision is detected against this object.
func on_player_contact(player: Player) -> void:
	if _bounce_on_cooldown:
		return
	_bounce_on_cooldown = true
	get_tree().create_timer(BOUNCE_COOLDOWN).timeout.connect(_clear_bounce_cooldown)
	player.take_damage(damage)
	var normal: Vector3 = (player.global_position - global_position).normalized()
	player.bounce(normal)


func _clear_bounce_cooldown() -> void:
	_bounce_on_cooldown = false
