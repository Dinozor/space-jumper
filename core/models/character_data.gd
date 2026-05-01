class_name CharacterData
extends Resource

## Per-character stat profile. Aerodynamics scales the drag applied to this character
## (0.5 = default, lower = floatier, higher = sluggish).

@export var character_id: String = ""
@export var display_name: String = ""
@export var cost: int = 0
@export var mesh_scene: PackedScene

## Base stats — multiplied by upgrade factors before applying to the player.
@export var move_speed: float = 8.0
@export var jump_force: float = 12.0
@export var aerodynamics: float = 1.0

## Per-stat upgrade counters (each tier multiplies the stat by upgrade_factor).
@export var upgrade_factor: float = 1.15
@export var max_upgrades_per_stat: int = 3
