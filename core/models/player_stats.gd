class_name PlayerStats
extends RefCounted

## Runtime player state: health, score, drift.

const MAX_HEALTH: int = 3

var health: int = MAX_HEALTH
var score: int = 0
var drift_distance: float = 0.0
