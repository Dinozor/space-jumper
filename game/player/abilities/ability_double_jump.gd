class_name AbilityDoubleJump
extends PlayerAbility

var _extra_jumps: int = 0


func consume_extra_jump() -> bool:
	if _extra_jumps > 0:
		_extra_jumps -= 1
		return true
	return false


func on_landed() -> void:
	_extra_jumps = 1
