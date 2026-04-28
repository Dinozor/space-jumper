class_name LevelSelect
extends Control

## Level selection screen. Populates buttons from GameState unlocked levels.

signal level_chosen(level_id: int)

@onready var _button_container: HBoxContainer = $ButtonContainer


func _ready() -> void:
	_populate_buttons()


func _populate_buttons() -> void:
	for id: int in GameState.unlocked_levels:
		var btn := Button.new()
		btn.text = "Level %d" % (id + 1)
		btn.pressed.connect(func() -> void: level_chosen.emit(id))
		_button_container.add_child(btn)
