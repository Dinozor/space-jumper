class_name Projectile
extends Area3D

## Fired by the shooting ability. Travels upward and destroys shootable debris.

const SPEED: float = 30.0
const LIFETIME: float = 3.0

var _timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.y += SPEED * delta
	_timer += delta
	if _timer >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("receive_hit"):
		body.receive_hit()
	queue_free()
