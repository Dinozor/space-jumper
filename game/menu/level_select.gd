class_name LevelSelect
extends Control

## Level-select screen — orbital map layout. Builds all UI in code; scene is a blank Control.

signal level_chosen(level_id: int)

const _ARC_RX_RATIO: float = 0.46
const _ARC_RY_RATIO: float = 0.28
const _ARC_CENTER_Y_OFFSET: float = 120.0
const _ANGLE_START: float = PI * 1.18
const _ANGLE_END: float = PI * 1.82
const _NODE_SIZE: Vector2 = Vector2(64.0, 44.0)
const _BOSS_NODE_SIZE: Vector2 = Vector2(56.0, 56.0)

var _pulse_nodes: Array[Button] = []
var _time: float = 0.0


func _ready() -> void:
	_build_ui()


func _process(delta: float) -> void:
	_time += delta
	var alpha: float = 0.85 + 0.15 * sin(_time * 3.0)
	for btn: Button in _pulse_nodes:
		btn.modulate.a = alpha


func _build_ui() -> void:
	_add_background()
	_add_planet()
	_add_stars()
	_add_orbit_arc()
	_add_level_nodes()
	_add_enemy_node()
	_add_back_button()


func _add_background() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.024, 0.031, 0.059)
	add_child(bg)


func _add_planet() -> void:
	var s: Vector2 = get_viewport_rect().size
	var diameter: float = s.x * 1.35
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.118, 0.2, 0.439)
	style.set_corner_radius_all(int(diameter * 0.5))
	style.shadow_color = Color(0.133, 0.267, 0.667, 0.3)
	style.shadow_size = 28
	var planet: Panel = Panel.new()
	planet.add_theme_stylebox_override("panel", style)
	planet.size = Vector2(diameter, diameter)
	planet.position = Vector2(s.x * 0.5 - diameter * 0.5, s.y - diameter * 0.4)
	add_child(planet)


func _add_stars() -> void:
	var s: Vector2 = get_viewport_rect().size
	var pts: Array[Vector2] = [
		Vector2(0.10, 0.06),
		Vector2(0.29, 0.11),
		Vector2(0.52, 0.04),
		Vector2(0.72, 0.09),
		Vector2(0.89, 0.19),
		Vector2(0.05, 0.36),
		Vector2(0.94, 0.25),
		Vector2(0.18, 0.50),
	]
	for p: Vector2 in pts:
		var star: ColorRect = ColorRect.new()
		star.size = Vector2(2.0, 2.0)
		star.color = Color(1.0, 1.0, 1.0, 0.7)
		star.position = p * s
		add_child(star)


func _arc_center() -> Vector2:
	var s: Vector2 = get_viewport_rect().size
	return Vector2(s.x * 0.5, s.y + _ARC_CENTER_Y_OFFSET)


func _arc_pos_t(t: float) -> Vector2:
	var angle: float = lerp(_ANGLE_START, _ANGLE_END, t)
	var s: Vector2 = get_viewport_rect().size
	return (
		_arc_center() + Vector2(cos(angle) * s.x * _ARC_RX_RATIO, sin(angle) * s.y * _ARC_RY_RATIO)
	)


func _arc_pos(index: int, count: int) -> Vector2:
	return _arc_pos_t(float(index) / float(maxi(count - 1, 1)))


func _add_orbit_arc() -> void:
	var arc: Line2D = Line2D.new()
	arc.width = 1.0
	arc.default_color = Color(1.0, 1.0, 1.0, 0.12)
	var steps: int = 60
	for i: int in range(steps + 1):
		arc.add_point(_arc_pos_t(float(i) / float(steps)))
	add_child(arc)


func _add_level_nodes() -> void:
	var regular: Array[LevelData] = []
	for lv: LevelData in GameState.levels:
		if not lv.has_boss:
			regular.append(lv)
	regular.sort_custom(func(a: LevelData, b: LevelData) -> bool: return a.level_id < b.level_id)
	for i: int in regular.size():
		_add_node(regular[i], _arc_pos(i, regular.size()), _NODE_SIZE, false)


func _add_node(lv: LevelData, center: Vector2, node_size: Vector2, is_boss: bool) -> void:
	var state: String = _level_state(lv)
	var btn: Button = _make_node_button(lv, node_size, state, is_boss)
	btn.position = center - node_size * 0.5
	if state == "locked":
		btn.disabled = true
		btn.tooltip_text = _unlock_hint(lv)
	else:
		btn.pressed.connect(func() -> void: _on_level_chosen(lv.level_id))
	if state == "active":
		_pulse_nodes.append(btn)
	add_child(btn)
	_add_node_label(lv.display_name, center + Vector2(0.0, node_size.y * 0.5 + 4.0))
	if not is_boss:
		_add_scores_button(lv.level_id, center + Vector2(0.0, node_size.y * 0.5 + 22.0))


func _make_node_button(lv: LevelData, node_size: Vector2, state: String, is_boss: bool) -> Button:
	var btn: Button = Button.new()
	var state_label: String = "✓" if state == "beaten" else str(lv.level_id)
	btn.text = state_label
	btn.custom_minimum_size = node_size
	btn.size = node_size
	btn.add_theme_font_size_override("font_size", 14)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_boss:
		style.bg_color = Color(0.102, 0.02, 0.02)
		style.border_color = Color(1.0, 0.2, 0.2) if state != "locked" else Color(0.4, 0.1, 0.1)
		style.set_corner_radius_all(int(node_size.x * 0.5))
	elif state == "beaten":
		style.bg_color = Color(0.075, 0.165, 0.4)
		style.border_color = Color(0.29, 0.608, 1.0)
		style.set_corner_radius_all(6)
	elif state == "active":
		style.bg_color = Color(0.102, 0.2, 0.333)
		style.border_color = Color(0.667, 0.8, 1.0)
		style.set_corner_radius_all(6)
	else:
		style.bg_color = Color(0.102, 0.102, 0.102)
		style.border_color = Color(0.267, 0.267, 0.267)
		style.set_corner_radius_all(6)
		btn.modulate = Color(1.0, 1.0, 1.0, 0.4)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)
	return btn


func _add_node_label(text: String, pos: Vector2) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = pos - Vector2(60.0, 0.0)
	lbl.custom_minimum_size = Vector2(120.0, 14.0)
	add_child(lbl)


func _add_scores_button(level_id: int, pos: Vector2) -> void:
	var btn: Button = Button.new()
	btn.text = "Scores"
	btn.add_theme_font_size_override("font_size", 9)
	btn.custom_minimum_size = Vector2(60.0, 18.0)
	btn.position = pos - Vector2(30.0, 0.0)
	btn.pressed.connect(func() -> void: _on_scores_pressed(level_id))
	add_child(btn)


func _add_enemy_node() -> void:
	var boss_lv: LevelData = null
	for lv: LevelData in GameState.levels:
		if lv.has_boss:
			boss_lv = lv
			break
	if boss_lv == null:
		return
	var s: Vector2 = get_viewport_rect().size
	var center: Vector2 = Vector2(s.x - 60.0, 56.0)
	_add_node(boss_lv, center, _BOSS_NODE_SIZE, true)


func _add_back_button() -> void:
	var btn: Button = Button.new()
	btn.text = "Back"
	btn.add_theme_font_size_override("font_size", 16)
	btn.custom_minimum_size = Vector2(120.0, 36.0)
	var s: Vector2 = get_viewport_rect().size
	btn.position = Vector2(s.x * 0.5 - 60.0, s.y - 52.0)
	btn.pressed.connect(_on_back_pressed)
	add_child(btn)


func _level_state(lv: LevelData) -> String:
	if lv.level_id not in GameState.unlocked_levels:
		return "locked"
	var key: String = str(lv.level_id)
	if key in GameState.scoreboard:
		for entry: Dictionary in GameState.scoreboard[key]:
			if entry.get("result", "") == "WON":
				return "beaten"
	return "active"


func _unlock_hint(lv: LevelData) -> String:
	for other: LevelData in GameState.levels:
		if other.level_id == lv.level_id - 1:
			return 'Beat "%s" to unlock' % other.display_name
	return "Locked"


func _on_level_chosen(level_id: int) -> void:
	AudioManager.play_button()
	GameState.current_level = level_id
	level_chosen.emit(level_id)
	get_tree().change_scene_to_file("res://game/gameplay/game.tscn")


func _on_scores_pressed(level_id: int) -> void:
	AudioManager.play_button()
	GameState.scoreboard_open_level = level_id
	GameState.scoreboard_return_path = "res://game/menu/level_select.tscn"
	get_tree().change_scene_to_file("res://game/ui/scoreboard.tscn")


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
