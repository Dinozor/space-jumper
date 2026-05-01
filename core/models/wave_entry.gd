class_name WaveEntry
extends Resource

## One object within a SpawnWave: what to spawn and where relative to the wave origin.

@export var scene: PackedScene
@export var x_offset: float = 0.0
@export var y_offset: float = 0.0
@export var z_offset: float = 0.0
@export var is_centered: bool = false
