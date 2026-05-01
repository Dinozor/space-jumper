class_name SpawnWave
extends Resource

## A curated group of objects spawned together as a formation.
## The spawner picks a wave occasionally instead of a single random object.

@export var weight: float = 1.0
@export var entries: Array[WaveEntry] = []
