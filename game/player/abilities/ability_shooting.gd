class_name AbilityShooting
extends PlayerAbility

## Fires upward projectiles that destroy shootable-tagged debris on hit.

const FIRE_COOLDOWN: float = 0.4

@export var projectile_scene: PackedScene

var _cooldown: float = 0.0


func tick(player: Player, delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("shoot") and _cooldown <= 0.0 and not player.input_locked:
		_fire(player)


func _fire(player: Player) -> void:
	if projectile_scene == null:
		return
	_cooldown = FIRE_COOLDOWN
	var proj: Node3D = projectile_scene.instantiate()
	player.get_parent().add_child(proj)
	proj.global_position = player.global_position + Vector3(0.0, 1.0, 0.0)
