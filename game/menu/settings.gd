class_name Settings
extends Control

## Settings screen: audio toggles and control remapping.

signal back_pressed

const _ACTIONS: Array[String] = ["move_left", "move_right", "move_forward", "move_back"]
const _ACTION_LABELS: Array[String] = ["Move Left", "Move Right", "Move Forward", "Move Back"]

var _remapping_action: String = ""
var _remap_buttons: Dictionary = {}
var _key_labels: Dictionary = {}

var _confirm_delete_save: ConfirmationDialog
var _confirm_reset_scores: ConfirmationDialog


func _ready() -> void:
	var vbox: VBoxContainer = _build_vbox()
	add_child(vbox)
	vbox.add_child(_make_label("SETTINGS", 28))
	vbox.add_child(HSeparator.new())
	_build_audio_section(vbox)
	_build_controls_section(vbox)
	if GameState.settings_from_main_menu:
		_build_data_section(vbox)
	_build_back_button(vbox)


func _unhandled_input(event: InputEvent) -> void:
	if _remapping_action.is_empty():
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event.echo or not key_event.pressed:
		return
	get_viewport().set_input_as_handled()
	if key_event.physical_keycode == KEY_ESCAPE:
		_cancel_remap()
		return
	_apply_remap(_remapping_action, key_event)
	_remapping_action = ""


func _build_vbox() -> VBoxContainer:
	var vbox: VBoxContainer = VBoxContainer.new()
	var half_height: float = 330.0 if GameState.settings_from_main_menu else 280.0
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -220.0
	vbox.offset_top = -half_height
	vbox.offset_right = 220.0
	vbox.offset_bottom = half_height
	vbox.add_theme_constant_override("separation", 10)
	return vbox


func _make_label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _make_button(text: String) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 20)
	return btn


func _build_audio_section(vbox: VBoxContainer) -> void:
	vbox.add_child(_make_label("AUDIO", 18))
	_build_toggle_row(
		vbox,
		"Music",
		AudioManager.music_enabled,
		func(on: bool) -> void: AudioManager.music_enabled = on
	)
	_build_toggle_row(
		vbox,
		"Sound Effects",
		AudioManager.sfx_enabled,
		func(on: bool) -> void: AudioManager.sfx_enabled = on
	)
	vbox.add_child(HSeparator.new())


func _build_toggle_row(
	vbox: VBoxContainer,
	label_text: String,
	initial_value: bool,
	callback: Callable,
) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_child(_make_label(label_text, 20))
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var toggle: CheckButton = CheckButton.new()
	toggle.button_pressed = initial_value
	toggle.toggled.connect(callback)
	row.add_child(toggle)
	vbox.add_child(row)


func _build_controls_section(vbox: VBoxContainer) -> void:
	vbox.add_child(_make_label("CONTROLS", 18))
	for i: int in _ACTIONS.size():
		_build_remap_row(vbox, _ACTIONS[i], _ACTION_LABELS[i])
	vbox.add_child(HSeparator.new())


func _build_remap_row(vbox: VBoxContainer, action: String, label_text: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_child(_make_label(label_text, 18))
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var key_label: Label = _make_label(_get_key_text(action), 18)
	row.add_child(key_label)
	var btn: Button = _make_button("Remap")
	btn.custom_minimum_size.x = 90.0
	btn.pressed.connect(func() -> void: _start_remap(action))
	_remap_buttons[action] = btn
	_key_labels[action] = key_label
	row.add_child(btn)
	vbox.add_child(row)


func _build_data_section(vbox: VBoxContainer) -> void:
	vbox.add_child(_make_label("DATA", 18))
	var delete_btn: Button = _make_button("Delete Save")
	delete_btn.pressed.connect(_on_delete_save_pressed)
	vbox.add_child(delete_btn)
	var reset_btn: Button = _make_button("Reset Scoreboard")
	reset_btn.pressed.connect(_on_reset_scores_pressed)
	vbox.add_child(reset_btn)
	vbox.add_child(HSeparator.new())

	_confirm_delete_save = ConfirmationDialog.new()
	_confirm_delete_save.title = "Delete Save"
	_confirm_delete_save.dialog_text = ("This will delete all progression (currency, unlocks, upgrades). Scores are kept. Continue?")
	_confirm_delete_save.confirmed.connect(_on_delete_save_confirmed)
	add_child(_confirm_delete_save)

	_confirm_reset_scores = ConfirmationDialog.new()
	_confirm_reset_scores.title = "Reset Scoreboard"
	_confirm_reset_scores.dialog_text = ("This will delete all scoreboard history. Progression is kept. Continue?")
	_confirm_reset_scores.confirmed.connect(_on_reset_scores_confirmed)
	add_child(_confirm_reset_scores)


func _on_delete_save_pressed() -> void:
	AudioManager.play_button()
	_confirm_delete_save.popup_centered()


func _on_delete_save_confirmed() -> void:
	SaveManager.delete_progression()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _on_reset_scores_pressed() -> void:
	AudioManager.play_button()
	_confirm_reset_scores.popup_centered()


func _on_reset_scores_confirmed() -> void:
	SaveManager.delete_scores()


func _build_back_button(vbox: VBoxContainer) -> void:
	var btn: Button = _make_button("BACK")
	btn.pressed.connect(_on_back_pressed)
	vbox.add_child(btn)


func _get_key_text(action: String) -> String:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		return "None"
	if events[0] is InputEventKey:
		return OS.get_keycode_string((events[0] as InputEventKey).physical_keycode)
	return events[0].as_text()


func _start_remap(action: String) -> void:
	if not _remapping_action.is_empty():
		return
	_remapping_action = action
	(_remap_buttons[action] as Button).text = "..."
	AudioManager.play_button()


func _cancel_remap() -> void:
	(_remap_buttons[_remapping_action] as Button).text = "Remap"
	_remapping_action = ""


func _apply_remap(action: String, event: InputEventKey) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	(_remap_buttons[action] as Button).text = "Remap"
	(_key_labels[action] as Label).text = OS.get_keycode_string(event.physical_keycode)


func _on_back_pressed() -> void:
	AudioManager.play_button()
	if back_pressed.get_connections().size() > 0:
		back_pressed.emit()
	else:
		get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
