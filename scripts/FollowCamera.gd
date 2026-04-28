extends Camera2D

# ──────────────────────────────────────────────
#  FollowCamera – follows the player upward only
#  (never scrolls down, Doodle Jump style)
# ──────────────────────────────────────────────

@export var follow_speed  := 5.0      # lerp speed
@export var lead_offset   := -180.0   # keep player lower-centre of screen

var _player : CharacterBody2D
var _target_y : float

func _ready() -> void:
	add_to_group("main_camera")
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0]
	_target_y = global_position.y

func _process(delta: float) -> void:
	if not _player:
		return
	# Only move camera up (lower y), never down
	var desired_y := _player.global_position.y + lead_offset
	if desired_y < _target_y:
		_target_y = lerp(_target_y, desired_y, follow_speed * delta)
	global_position.y = _target_y
