class_name AbilityBoostRecharge
extends PlayerAbility

## Passively refills the player's intro-boost jetpack fuel after a cooldown.
## Does not activate while boosting; cooldown starts when boost ends.

const RECHARGE_DELAY: float = 5.0
const RECHARGE_RATE: float = 0.5

var _cooldown: float = 0.0


func tick(player: Player, delta: float) -> void:
	if player.get_jetpack_fuel_ratio() > 0.0:
		_cooldown = RECHARGE_DELAY
		return
	if _cooldown > 0.0:
		_cooldown -= delta
		return
	player.refill_jetpack(RECHARGE_RATE * delta)
