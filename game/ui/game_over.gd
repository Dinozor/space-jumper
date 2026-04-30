class_name GameOver
extends CanvasLayer

## Game-over screen: shows result and provides restart / menu actions.

const _FONT: FontFile = preload("res://assets/kenney/ui/fonts/Kenney Future.ttf")

signal restart_pressed
signal menu_pressed

var _reason_messages: Dictionary

@onready var _reason_label: Label = $Panel/ReasonLabel
@onready var _restart_button: Button = $Panel/RestartButton
@onready var _menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	_reason_messages = {
		Game.EndState.DIED: "You were destroyed!",
		Game.EndState.DRIFTED: "You drifted away!",
		Game.EndState.LEFT_BEHIND: "You were left behind!",
		Game.EndState.WON: "You reached the station!",
	}
	_reason_label.add_theme_font_override("font", _FONT)
	_reason_label.add_theme_font_size_override("font_size", 28)
	for btn: Button in [_restart_button, _menu_button]:
		btn.add_theme_font_override("font", _FONT)
		btn.add_theme_font_size_override("font_size", 18)
	_restart_button.pressed.connect(_on_restart_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_restart_pressed() -> void:
	AudioManager.play_button()
	restart_pressed.emit()


func _on_menu_pressed() -> void:
	AudioManager.play_button()
	menu_pressed.emit()


func show_result(reason: Game.EndState) -> void:
	_reason_label.text = _reason_messages.get(reason, "Game Over")
	show()
