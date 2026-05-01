class_name LevelSelect
extends Control

## Level selection screen. Shows all levels; locked ones are disabled with a tooltip.

signal level_chosen(level_id: int)

@onready var _button_container: HBoxContainer = $VBox/ButtonContainer
@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_populate_buttons()


func _populate_buttons() -> void:
	for level: LevelData in GameState.levels:
		var unlocked: bool = level.level_id in GameState.unlocked_levels
		var btn: Button = Button.new()
		btn.text = (
			level.display_name if level.display_name != "" else "Level %d" % (level.level_id + 1)
		)
		if unlocked:
			btn.pressed.connect(func() -> void: _on_level_chosen(level.level_id))
		else:
			btn.disabled = true
			btn.modulate = Color(0.55, 0.55, 0.55)
			btn.tooltip_text = _unlock_hint(level.level_id)
		_button_container.add_child(btn)


func _unlock_hint(level_id: int) -> String:
	for level: LevelData in GameState.levels:
		if level.level_id == level_id - 1:
			var name: String = (
				level.display_name if level.display_name != "" else "Level %d" % level_id
			)
			return 'Beat "%s" to unlock' % name
	return "Locked"


func _on_level_chosen(level_id: int) -> void:
	AudioManager.play_button()
	GameState.current_level = level_id
	level_chosen.emit(level_id)
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
