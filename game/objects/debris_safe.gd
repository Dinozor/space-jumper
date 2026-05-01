class_name DebrisSafe
extends RigidBody3D

## Safe debris: player bounces off it without taking damage.

const BOUNCE_COOLDOWN: float = 0.5

@export var fall_speed: float = 8.0
@export var tags: PackedStringArray = []

var _bounce_on_cooldown: bool = false


func _ready() -> void:
	linear_velocity = Vector3(0.0, -fall_speed, 0.0)


## Called by the player when a slide collision is detected against this object.
func on_player_contact(player: Player, normal: Vector3) -> void:
	if _bounce_on_cooldown:
		return
	_bounce_on_cooldown = true
	get_tree().create_timer(BOUNCE_COOLDOWN).timeout.connect(_clear_bounce_cooldown)
	player.bounce(normal)


func _clear_bounce_cooldown() -> void:
	_bounce_on_cooldown = false
