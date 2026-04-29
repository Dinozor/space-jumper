## Stateless math helpers.

static func remap(
	value: float, from_min: float, from_max: float, to_min: float, to_max: float
) -> float:
	return to_min + (value - from_min) / (from_max - from_min) * (to_max - to_min)
