class_name GameOver
extends CanvasLayer

## Game-over screen: shows result and provides restart / menu actions.

signal restart_pressed
signal menu_pressed

@export var reason_messages: Dictionary = {
	"died": "You were destroyed!",
	"drifted": "You drifted away!",
	"left_behind": "You were left behind!",
	"won": "You reached the station!",
}

@onready var _reason_label: Label = $Panel/ReasonLabel
@onready var _restart_button: Button = $Panel/RestartButton
@onready var _menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	_restart_button.pressed.connect(restart_pressed.emit)
	_menu_button.pressed.connect(menu_pressed.emit)


func show_result(reason: String) -> void:
	_reason_label.text = reason_messages.get(reason, "Game Over")
	show()
