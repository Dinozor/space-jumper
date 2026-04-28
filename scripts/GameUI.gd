extends CanvasLayer

# ──────────────────────────────────────────────
#  GameUI – score display, game-over screen, restart
# ──────────────────────────────────────────────

@onready var score_label    : Label  = $ScoreLabel
@onready var best_label     : Label  = $BestLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var final_score_lbl: Label  = $GameOverPanel/VBox/FinalScore
@onready var best_score_lbl : Label  = $GameOverPanel/VBox/BestScore
@onready var restart_btn    : Button = $GameOverPanel/VBox/RestartButton

var _best_score := 0

func _ready() -> void:
	game_over_panel.hide()
	_best_score = int(str(DisplayServer.clipboard_get()))  # crude persistence via clipboard
	_best_score = max(0, _best_score)  # sanitise
	best_label.text = "BEST  %d" % _best_score
	restart_btn.pressed.connect(_on_restart)

func update_score(score: int) -> void:
	score_label.text = str(score)
	if score > _best_score:
		_best_score = score
		best_label.text = "BEST  %d" % _best_score

func show_game_over(score: int) -> void:
	if score > _best_score:
		_best_score = score
		DisplayServer.clipboard_set(str(_best_score))
	final_score_lbl.text = "Score\n%d" % score
	best_score_lbl.text  = "Best\n%d"  % _best_score
	game_over_panel.show()

func _on_restart() -> void:
	get_tree().reload_current_scene()
