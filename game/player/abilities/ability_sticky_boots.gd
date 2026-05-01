class_name AbilityStickyBoots
extends PlayerAbility

## Negates all lateral bounce velocity — player bounces straight up from walls.


func modify_lateral_bounce(_velocity: Vector3) -> Vector3:
	return Vector3.ZERO
