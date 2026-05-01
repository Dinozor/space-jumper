class_name SpawnTable
extends Resource

## Collection of SpawnEntry items and SpawnWaves; picks one by weighted random selection.

@export var entries: Array[SpawnEntry] = []
@export var waves: Array[SpawnWave] = []
## 0–1 probability that a wave fires instead of a single object (when waves exist).
@export var wave_chance: float = 0.25


## Returns a random SpawnWave or null (caller should fall back to pick()).
func pick_wave() -> SpawnWave:
	if waves.is_empty() or randf() > wave_chance:
		return null
	var total: float = 0.0
	for w: SpawnWave in waves:
		total += w.weight
	var roll: float = randf() * total
	for w: SpawnWave in waves:
		roll -= w.weight
		if roll <= 0.0:
			return w
	return waves[-1]


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
