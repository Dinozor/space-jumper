class_name Scoreboard
extends Control

## Full-screen scoreboard: level dropdown, Last 3 Attempts, All Attempts.

var _level_dropdown: OptionButton
var _last3_box: VBoxContainer
var _all_box: VBoxContainer
var _current_level_id: int = 0


func _ready() -> void:
	_current_level_id = GameState.scoreboard_open_level
	_build_ui()
	_populate_dropdown()
	_render()


func _build_ui() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_bottom = -60.0
	add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)

	var row: HBoxContainer = HBoxContainer.new()
	var level_label: Label = Label.new()
	level_label.text = "Level:"
	level_label.add_theme_font_size_override("font_size", 20)
	row.add_child(level_label)
	_level_dropdown = OptionButton.new()
	_level_dropdown.add_theme_font_size_override("font_size", 20)
	_level_dropdown.item_selected.connect(_on_level_selected)
	row.add_child(_level_dropdown)
	vbox.add_child(row)
	vbox.add_child(HSeparator.new())

	var last3_header: Label = Label.new()
	last3_header.text = "LAST 3 ATTEMPTS"
	last3_header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(last3_header)
	vbox.add_child(HSeparator.new())
	_last3_box = VBoxContainer.new()
	vbox.add_child(_last3_box)
	vbox.add_child(HSeparator.new())

	var all_header: Label = Label.new()
	all_header.text = "ALL ATTEMPTS"
	all_header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(all_header)
	vbox.add_child(HSeparator.new())
	_all_box = VBoxContainer.new()
	vbox.add_child(_all_box)

	var back_btn: Button = Button.new()
	back_btn.text = "BACK"
	back_btn.add_theme_font_size_override("font_size", 20)
	back_btn.anchor_left = 0.5
	back_btn.anchor_top = 1.0
	back_btn.anchor_right = 0.5
	back_btn.anchor_bottom = 1.0
	back_btn.offset_left = -80.0
	back_btn.offset_top = -55.0
	back_btn.offset_right = 80.0
	back_btn.offset_bottom = -10.0
	back_btn.pressed.connect(_on_back_pressed)
	add_child(back_btn)


func _populate_dropdown() -> void:
	_level_dropdown.clear()
	for level: LevelData in GameState.levels:
		var name: String = (
			level.display_name if level.display_name != "" else "Level %d" % (level.level_id + 1)
		)
		_level_dropdown.add_item(name, level.level_id)
	for i: int in _level_dropdown.item_count:
		if _level_dropdown.get_item_id(i) == _current_level_id:
			_level_dropdown.select(i)
			break


func _on_level_selected(index: int) -> void:
	_current_level_id = _level_dropdown.get_item_id(index)
	_render()


func _render() -> void:
	var key: String = str(_current_level_id)
	var raw_entries: Array = []
	if key in GameState.scoreboard:
		raw_entries = Array(GameState.scoreboard[key])

	var wins: Array = []
	var losses: Array = []
	for e: Variant in raw_entries:
		if str((e as Dictionary)["result"]) == "WON":
			wins.append(e)
		else:
			losses.append(e)
	wins.sort_custom(
		func(a: Variant, b: Variant) -> bool: return float(a["time"]) < float(b["time"])
	)
	losses.sort_custom(
		func(a: Variant, b: Variant) -> bool: return float(a["time"]) > float(b["time"])
	)
	var sorted_all: Array = wins + losses

	var ts_to_rank: Dictionary = {}
	for i: int in sorted_all.size():
		ts_to_rank[int((sorted_all[i] as Dictionary)["ts"])] = i + 1

	var latest_ts: int = -1
	for e: Variant in raw_entries:
		var ts: int = int((e as Dictionary)["ts"])
		if ts > latest_ts:
			latest_ts = ts

	var by_ts: Array = raw_entries.duplicate()
	by_ts.sort_custom(func(a: Variant, b: Variant) -> bool: return int(a["ts"]) > int(b["ts"]))
	var last3: Array = by_ts.slice(0, 3)

	_clear_box(_last3_box)
	if raw_entries.is_empty():
		_last3_box.add_child(_make_empty_label())
	else:
		for entry: Variant in last3:
			var d: Dictionary = entry as Dictionary
			var rank: int = ts_to_rank.get(int(d["ts"]), 0)
			_last3_box.add_child(_make_entry_row(rank, d, int(d["ts"]) == latest_ts))

	_clear_box(_all_box)
	if raw_entries.is_empty():
		_all_box.add_child(_make_empty_label())
	else:
		for i: int in sorted_all.size():
			var d: Dictionary = sorted_all[i] as Dictionary
			_all_box.add_child(_make_entry_row(i + 1, d, int(d["ts"]) == latest_ts))


func _clear_box(box: VBoxContainer) -> void:
	for child: Node in box.get_children():
		box.remove_child(child)
		child.queue_free()


func _make_empty_label() -> Label:
	var lbl: Label = Label.new()
	lbl.text = "No attempts yet."
	lbl.add_theme_font_size_override("font_size", 18)
	return lbl


func _make_entry_row(rank: int, entry: Dictionary, is_latest: bool) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)

	var rank_lbl: Label = Label.new()
	rank_lbl.text = "#%d" % rank
	rank_lbl.custom_minimum_size.x = 44.0
	rank_lbl.add_theme_font_size_override("font_size", 18)
	row.add_child(rank_lbl)

	var result_lbl: Label = Label.new()
	result_lbl.text = _format_result(str(entry["result"]))
	result_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_lbl.add_theme_font_size_override("font_size", 18)
	row.add_child(result_lbl)

	var time_lbl: Label = Label.new()
	time_lbl.text = _format_time(float(entry["time"]))
	time_lbl.custom_minimum_size.x = 80.0
	time_lbl.add_theme_font_size_override("font_size", 18)
	row.add_child(time_lbl)

	if is_latest:
		var dot: Label = Label.new()
		dot.text = "●"
		dot.add_theme_font_size_override("font_size", 18)
		row.add_child(dot)

	return row


func _format_result(result: String) -> String:
	match result:
		"WON":
			return "Win"
		"DIED":
			return "Died"
		"DRIFTED":
			return "Drifted"
		"LEFT_BEHIND":
			return "Left Behind"
		_:
			return result


func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	var tenths: int = int(seconds * 10.0) % 10
	return "%d:%02d.%d" % [mins, secs, tenths]


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file(GameState.scoreboard_return_path)
