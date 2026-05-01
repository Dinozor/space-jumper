class_name AbilityJetpack
extends PlayerAbility

## Purchasable jetpack: player holds Jump to activate sustained upward thrust.

const THRUST: float = 14.0
const FUEL_MAX: float = 3.0
const RECHARGE_DELAY: float = 4.0

var fuel: float = FUEL_MAX
var _recharge_timer: float = 0.0
var _active: bool = false


func tick(player: Player, delta: float) -> void:
	if Input.is_action_pressed("jump") and not player.input_locked and fuel > 0.0:
		_active = true
		fuel -= delta
		player.velocity.y = THRUST
		_recharge_timer = RECHARGE_DELAY
	else:
		_active = false
		if _recharge_timer > 0.0:
			_recharge_timer -= delta
		else:
			fuel = minf(fuel + delta * (FUEL_MAX / RECHARGE_DELAY), FUEL_MAX)
