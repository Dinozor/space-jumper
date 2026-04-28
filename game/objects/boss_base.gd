class_name BossBase
extends Node3D

## Base class for boss objects. Override _on_hit() in derived bosses.

signal defeated

@export var max_health: int = 5

var _health: int


func _ready() -> void:
	_health = max_health


func hit(damage: int) -> void:
	_health -= damage
	_on_hit()
	if _health <= 0:
		defeated.emit()
		queue_free()


func _on_hit() -> void:
	pass
