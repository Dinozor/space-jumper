class_name PauseMenu
extends CanvasLayer

## Pause overlay: shown on Esc; contains Resume, Settings, and Exit to Menu.

@export var settings_scene: PackedScene

var _main_panel: Control
var _settings_control: Settings


func _ready() -> void:
	_build_overlay()
	_build_main_panel()
	_build_settings_panel()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_just_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _settings_control != null and _settings_control.visible:
		_on_settings_back()
	else:
		_on_resume()


func _build_overlay() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.6)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)


func _build_main_panel() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -160.0
	panel.offset_top = -150.0
	panel.offset_right = 160.0
	panel.offset_bottom = 150.0
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	_populate_main_panel(vbox)
	add_child(panel)
	_main_panel = panel


func _populate_main_panel(vbox: VBoxContainer) -> void:
	var title: Label = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())
	_add_button(vbox, "Resume", _on_resume)
	_add_button(vbox, "Settings", _on_settings)
	_add_button(vbox, "Exit to Menu", _on_menu)


func _add_button(vbox: VBoxContainer, label: String, callback: Callable) -> void:
	var btn: Button = Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(callback)
	vbox.add_child(btn)


func _build_settings_panel() -> void:
	if settings_scene == null:
		return
	_settings_control = settings_scene.instantiate() as Settings
	_settings_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_control.back_pressed.connect(_on_settings_back)
	_settings_control.hide()
	add_child(_settings_control)


func _on_resume() -> void:
	AudioManager.play_button()
	get_tree().paused = false
	hide()


func _on_settings() -> void:
	AudioManager.play_button()
	_main_panel.hide()
	if _settings_control != null:
		_settings_control.show()


func _on_settings_back() -> void:
	if _settings_control != null:
		_settings_control.hide()
	_main_panel.show()


func _on_menu() -> void:
	AudioManager.play_button()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
