class_name AbilityGrapplingGloves
extends PlayerAbility

## Reduces lateral bounce velocity by 60%, making wall-chaining easier.

const REDUCTION: float = 0.4


func modify_lateral_bounce(velocity: Vector3) -> Vector3:
	return velocity * REDUCTION
