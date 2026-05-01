class_name LevelSelect
extends Control

## Level selection screen. Populates buttons from LevelLoader data via GameState.

signal level_chosen(level_id: int)

@onready var _title: Label = $VBox/Title
@onready var _button_container: HBoxContainer = $VBox/ButtonContainer
@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_populate_buttons()


func _populate_buttons() -> void:
	for level: LevelData in GameState.levels:
		if level.level_id not in GameState.unlocked_levels:
			continue
		var btn: Button = Button.new()
		btn.text = (
			level.display_name if level.display_name != "" else "Level %d" % (level.level_id + 1)
		)
		btn.pressed.connect(func() -> void: _on_level_chosen(level.level_id))
		_button_container.add_child(btn)


func _on_level_chosen(level_id: int) -> void:
	AudioManager.play_button()
	GameState.current_level = level_id
	level_chosen.emit(level_id)
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
