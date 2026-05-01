class_name LevelData
extends Resource

## Data definition for a single level.

@export var level_id: int = 0
@export var display_name: String = ""
@export var debris_theme: String = ""
@export var environment_theme: String = ""
@export var has_boss: bool = false
@export var fall_speed: float = 10.0
@export var corridor_radius: float = 8.0
@export var sections: Array[LevelSection] = []
@export var has_cable_ending: bool = false
