class_name SpawnTable
extends Resource

## Collection of SpawnEntry items; picks one by weighted random selection.

@export var entries: Array[SpawnEntry] = []


## Returns a random entry eligible at the given difficulty, weighted by entry.weight.
func pick(difficulty: float) -> SpawnEntry:
	var eligible: Array[SpawnEntry] = []
	var total: float = 0.0
	for e: SpawnEntry in entries:
		if e.scene != null and e.min_difficulty <= difficulty:
			eligible.append(e)
			total += e.weight
	if eligible.is_empty():
		return null
	var roll: float = randf() * total
	for e: SpawnEntry in eligible:
		roll -= e.weight
		if roll <= 0.0:
			return e
	return eligible[-1]
