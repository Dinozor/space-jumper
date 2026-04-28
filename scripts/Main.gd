extends Node2D

# ──────────────────────────────────────────────
#  Main – wires player, camera, spawner, and UI
# ──────────────────────────────────────────────

@onready var player  : CharacterBody2D = $Player
@onready var ui      : CanvasLayer      = $GameUI
@onready var spawner : Node2D           = $WallSpawner

func _ready() -> void:
	player.score_changed.connect(ui.update_score)
	player.died.connect(_on_player_died)

func _on_player_died() -> void:
	ui.show_game_over(player._score)
