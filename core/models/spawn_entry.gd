class_name SpawnEntry
extends Resource

## One entry in a SpawnTable: what object to spawn and how often.

@export var scene: PackedScene
@export var weight: float = 1.0
@export var min_difficulty: float = 0.0
@export var fall_speed_override: float = 0.0
@export var is_centered: bool = false
