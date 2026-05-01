class_name LevelSelect
extends Control

## Level selection screen. Populates buttons from LevelLoader data via GameState.

signal level_chosen(level_id: int)

const _FONT: FontFile = preload("res://assets/kenney/ui/fonts/Kenney Future.ttf")

@onready var _title: Label = $VBox/Title
@onready var _button_container: HBoxContainer = $VBox/ButtonContainer
@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_style_label(_title, 26)
	_style_button(_back_button)
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
		_style_button(btn)
		btn.pressed.connect(func() -> void: _on_level_chosen(level.level_id))
		_button_container.add_child(btn)


func _style_label(label: Label, font_size: int) -> void:
	label.add_theme_font_override("font", _FONT)
	label.add_theme_font_size_override("font_size", font_size)


func _style_button(btn: Button) -> void:
	btn.add_theme_font_override("font", _FONT)
	btn.add_theme_font_size_override("font_size", 22)


func _on_level_chosen(level_id: int) -> void:
	AudioManager.play_button()
	GameState.current_level = level_id
	level_chosen.emit(level_id)
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
