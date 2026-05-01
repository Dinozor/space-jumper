class_name PlayerAbility
extends Node

## Base class for all player abilities. Abilities are added as children of
## the Player node; each hook is called by the player at defined points.
## No if-checks for specific ability types exist in player code.


## Called every physics frame.
func tick(_player: Player, _delta: float) -> void:
	pass


## Called immediately after the player bounces off an object.
## Return the modified lateral bounce velocity.
func modify_lateral_bounce(velocity: Vector3) -> Vector3:
	return velocity


## Return true and consume the extra jump to allow an aerial jump.
func consume_extra_jump() -> bool:
	return false


## Called when the player lands (is_on_floor becomes true).
func on_landed() -> void:
	pass
