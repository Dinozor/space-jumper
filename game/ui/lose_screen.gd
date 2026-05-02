class_name LoseScreen
extends CanvasLayer

## Lose screen: shows failure reason and a contextual retry button.

signal retry_pressed
signal menu_pressed

const _REASON_MESSAGES: Dictionary = {
	Game.EndState.DIED: "You were destroyed!",
	Game.EndState.DRIFTED: "You drifted away!",
	Game.EndState.LEFT_BEHIND: "You were left behind!",
}

@onready var _result_label: Label = $Panel/ResultLabel
@onready var _retry_button: Button = $Panel/RetryButton
@onready var _menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


## Shows the lose screen with a contextual failure message.
## [param attempt_count] of 1 shows "Try Again", 2+ shows "Keep Trying".
func show_result(reason: Game.EndState, attempt_count: int) -> void:
	_result_label.text = _REASON_MESSAGES.get(reason, "Game Over")
	_retry_button.text = "Try Again" if attempt_count <= 1 else "Keep Trying"
	show()


func _on_retry_pressed() -> void:
	AudioManager.play_button()
	retry_pressed.emit()


func _on_menu_pressed() -> void:
	AudioManager.play_button()
	menu_pressed.emit()
