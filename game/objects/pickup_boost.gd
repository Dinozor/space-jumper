class_name PickupBoost
extends Area3D

## Boost pickup: gives the player a strong upward burst to escape sparse-debris zones.

signal collected

@export var fall_speed: float = 7.0
@export var boost_force: float = 22.0

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _collected:
		return
	position.y -= fall_speed * delta


func _on_body_entered(body: Node3D) -> void:
	if _collected or not (body is Player) or not body.is_physics_processing():
		return
	_collected = true
	(body as Player).apply_boost(boost_force)
	collected.emit()
	queue_free()
