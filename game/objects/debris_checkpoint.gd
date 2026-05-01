class_name DebrisCheckpoint
extends RigidBody3D

## Static checkpoint platform: does not fall, bounces the player upward on contact.

const BOUNCE_COOLDOWN: float = 0.5

var _bounce_on_cooldown: bool = false


func _ready() -> void:
	gravity_scale = 0.0


func on_player_contact(player: Player, normal: Vector3) -> void:
	if _bounce_on_cooldown:
		return
	_bounce_on_cooldown = true
	get_tree().create_timer(BOUNCE_COOLDOWN).timeout.connect(_clear_bounce_cooldown)
	player.bounce(normal)


func _clear_bounce_cooldown() -> void:
	_bounce_on_cooldown = false
