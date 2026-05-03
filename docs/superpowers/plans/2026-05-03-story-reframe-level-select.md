# Story Reframe + Level Select Orbital Map — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace generic level names with exploded-station sections, update GameState defaults to match new IDs, and replace the VBox level select list with an orbital map UI.

**Architecture:** Three independent changes landed in sequence: (1) fix GameState defaults so the new level ID range (1–6) works correctly; (2) delete old `.tres` files and create six new ones; (3) completely replace `level_select.gd` and strip `level_select.tscn` to a blank canvas. Main menu gets a one-line subtitle addition.

**Tech Stack:** Godot 4 GDScript, `.tres` resource files, `StyleBoxFlat`, `Line2D`, `Panel`.

---

## File Map

| Action | File | What changes |
|--------|------|-------------|
| Modify | `core/autoloads/game_state.gd` | `current_level` and `unlocked_levels` defaults → 1 |
| Modify | `core/utils/save_manager.gd` | `delete_progression` reset → unlocked `[1]` |
| Delete | `resources/levels/test_level.tres` | replaced |
| Delete | `resources/levels/level_training.tres` | replaced |
| Delete | `resources/levels/level_02.tres` | replaced |
| Create | `resources/levels/cargo_bay.tres` | level_id=1, first free level |
| Create | `resources/levels/reactor_core.tres` | level_id=2 |
| Create | `resources/levels/bridge.tres` | level_id=3 |
| Create | `resources/levels/command_deck.tres` | level_id=4 |
| Create | `resources/levels/hull_section.tres` | level_id=5 |
| Create | `resources/levels/enemy_ship.tres` | level_id=6, has_boss=true |
| Modify | `game/menu/level_select.tscn` | strip VBox; root Control + script only |
| Modify | `game/menu/level_select.gd` | full rewrite — orbital map |
| Modify | `game/menu/main_menu.tscn` | add subtitle Label |

---

## Task 1: Fix GameState defaults for new level IDs

The old first level was `level_id=0`. The new first level is `level_id=1`. Two files store `0` as a hardcoded default and must be updated before any level files are changed.

**Files:**
- Modify: `core/autoloads/game_state.gd:10-11`
- Modify: `core/utils/save_manager.gd` (the `delete_progression` reset block)

- [ ] **Step 1: Update `game_state.gd` defaults**

Open `core/autoloads/game_state.gd`. Change lines 10–11 from:
```gdscript
var current_level: int = 0
...
var unlocked_levels: Array[int] = [0]
```
to:
```gdscript
var current_level: int = 1
...
var unlocked_levels: Array[int] = [1]
```

- [ ] **Step 2: Update `save_manager.gd` reset**

Open `core/utils/save_manager.gd`. In `delete_progression()`, find the block that resets `unlocked_levels`:
```gdscript
GameState.unlocked_levels.clear()
GameState.unlocked_levels.append(0)
```
Change to:
```gdscript
GameState.unlocked_levels.clear()
GameState.unlocked_levels.append(1)
```

- [ ] **Step 3: Validate**

```bash
~/.local/share/nvim/mason/bin/gdformat . && timeout 30 godot --headless --check-only 2>&1 | grep -E "^ERROR|SCRIPT ERROR"
```
Expected: no ERROR lines. Exit code 124 (timeout) is correct.

- [ ] **Step 4: Commit**

```bash
git add core/autoloads/game_state.gd core/utils/save_manager.gd
git commit -m "fix(levels): update default level ID from 0 to 1 for new level numbering"
```

---

## Task 2: Replace level .tres files

Delete the three old level files and create six new ones matching the exploded-station arc. The LevelData script UID is `uid://poq7ts01dtmv` — keep it in all new files.

**Files:**
- Delete: `resources/levels/test_level.tres`, `resources/levels/level_training.tres`, `resources/levels/level_02.tres`
- Create: six new `.tres` files in `resources/levels/`

- [ ] **Step 1: Delete old files**

```bash
rm resources/levels/test_level.tres resources/levels/level_training.tres resources/levels/level_02.tres
```

- [ ] **Step 2: Create `resources/levels/cargo_bay.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 1
display_name = "Cargo Bay"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 7.0
drag = 0.35
corridor_radius = 10.0
has_cable_ending = true
level_reward = 100
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 3: Create `resources/levels/reactor_core.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 2
display_name = "Reactor Core"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 9.0
drag = 0.4
corridor_radius = 10.0
has_cable_ending = true
level_reward = 150
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 4: Create `resources/levels/bridge.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 3
display_name = "Bridge"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 11.0
drag = 0.45
corridor_radius = 10.0
has_cable_ending = true
level_reward = 200
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 5: Create `resources/levels/command_deck.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 4
display_name = "Command Deck"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 13.0
drag = 0.5
corridor_radius = 10.0
has_cable_ending = true
level_reward = 250
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 6: Create `resources/levels/hull_section.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 5
display_name = "Hull Section"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 15.0
drag = 0.55
corridor_radius = 10.0
has_cable_ending = true
level_reward = 300
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 7: Create `resources/levels/enemy_ship.tres`**

```
[gd_resource type="Resource" script_class="LevelData" format=3]

[ext_resource type="Script" uid="uid://poq7ts01dtmv" path="res://core/models/level_data.gd" id="Script_LevelData"]

[resource]
script = ExtResource("Script_LevelData")
level_id = 6
display_name = "Enemy Ship"
debris_theme = "Generic"
environment_theme = "Space"
station_escape_speed = 12.0
drag = 0.4
corridor_radius = 10.0
has_boss = true
has_cable_ending = false
level_reward = 500
metadata/_custom_type_script = "uid://poq7ts01dtmv"
```

- [ ] **Step 8: Validate**

```bash
~/.local/share/nvim/mason/bin/gdformat . && timeout 30 godot --headless --check-only 2>&1 | grep -E "^ERROR|SCRIPT ERROR"
```
Expected: no ERROR lines, exit 124.

- [ ] **Step 9: Commit**

```bash
git add resources/levels/
git commit -m "level: replace test levels with exploded-station arc (6 levels)"
```

---

## Task 3: Rewrite level_select.tscn

Strip the scene to a blank `Control` with the script attached. All UI is built in GDScript.

**Files:**
- Modify: `game/menu/level_select.tscn`

- [ ] **Step 1: Replace the scene file**

Write the entire file:

```
[gd_scene format=3 uid="uid://levelselect1"]

[ext_resource type="Script" path="res://game/menu/level_select.gd" id="Script_1"]

[node name="LevelSelect" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("Script_1")
```

- [ ] **Step 2: Validate scene parses**

```bash
timeout 30 godot --headless --check-only 2>&1 | grep -E "^ERROR|SCRIPT ERROR"
```
Expected: no ERROR lines.

---

## Task 4: Rewrite level_select.gd — orbital map

Full replacement. Builds all UI in GDScript: background, stars, planet arc, orbit line, level nodes with scores buttons, enemy ship node, back button.

**Files:**
- Modify: `game/menu/level_select.gd`

- [ ] **Step 1: Write the full file**

```gdscript
class_name LevelSelect
extends Control

## Level selection screen — orbital map layout.
## All UI nodes are built in code; the scene is a blank Control.

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
		Vector2(0.10, 0.06), Vector2(0.29, 0.11), Vector2(0.52, 0.04),
		Vector2(0.72, 0.09), Vector2(0.89, 0.19), Vector2(0.05, 0.36),
		Vector2(0.94, 0.25), Vector2(0.18, 0.50),
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


func _arc_pos(index: int, count: int) -> Vector2:
	var t: float = float(index) / float(maxi(count - 1, 1))
	var angle: float = lerp(_ANGLE_START, _ANGLE_END, t)
	var s: Vector2 = get_viewport_rect().size
	return _arc_center() + Vector2(cos(angle) * s.x * _ARC_RX_RATIO, sin(angle) * s.y * _ARC_RY_RATIO)


func _add_orbit_arc() -> void:
	var arc: Line2D = Line2D.new()
	arc.width = 1.0
	arc.default_color = Color(1.0, 1.0, 1.0, 0.12)
	var steps: int = 60
	var s: Vector2 = get_viewport_rect().size
	var center: Vector2 = _arc_center()
	for i: int in range(steps + 1):
		var t: float = float(i) / float(steps)
		var angle: float = lerp(_ANGLE_START, _ANGLE_END, t)
		arc.add_point(center + Vector2(cos(angle) * s.x * _ARC_RX_RATIO, sin(angle) * s.y * _ARC_RY_RATIO))
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
	var state_label: String = "✓" if state == "beaten" else ("🔒" if state == "locked" else str(lv.level_id))
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
```

- [ ] **Step 2: Validate**

```bash
~/.local/share/nvim/mason/bin/gdformat . && timeout 30 godot --headless --check-only 2>&1 | grep -E "^ERROR|SCRIPT ERROR"
```
Expected: no ERROR lines, exit 124.

- [ ] **Step 3: Manual check — open game and navigate to Level Select**

```bash
godot --main-scene game/menu/main_menu.tscn &
```
Open the game, click "Level Select". Expected:
- Dark space background with stars
- Blue planet arc visible at the bottom
- Dashed orbit arc above it
- "Cargo Bay" node (level 1) glowing/pulsing — it's the first active level
- Remaining nodes locked/dimmed
- Enemy Ship node in upper-right corner
- "Back" button at the bottom

- [ ] **Step 4: Commit**

```bash
git add game/menu/level_select.tscn game/menu/level_select.gd
git commit -m "feat(ui): replace level select list with orbital map"
```

---

## Task 5: Add story subtitle to main menu

Add a one-line story subtitle below the game title so the setting is immediately clear on first open.

**Files:**
- Modify: `game/menu/main_menu.tscn`

- [ ] **Step 1: Add Subtitle label to main_menu.tscn**

Open `game/menu/main_menu.tscn`. Add a `Label` node as the first child of `VBox`, before `PlayButton`:

```
[node name="Subtitle" type="Label" parent="VBox"]
layout_mode = 2
text = "Your station is in pieces. Put it back together."
horizontal_alignment = 1
theme_override_font_sizes/font_size = 13
modulate = Color(0.7, 0.75, 0.85, 1.0)
```

The full updated tscn (add the new node block after the VBox node and before PlayButton):

```
[gd_scene format=3 uid="uid://iuar7gfvkn0p"]

[ext_resource type="Script" uid="uid://bim8til2hxk2" path="res://game/menu/main_menu.gd" id="Script_1"]

[node name="MainMenu" type="Control" unique_id=874603690]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("Script_1")

[node name="VBox" type="VBoxContainer" parent="." unique_id=1454432647]
layout_mode = 0
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -120.0
offset_top = -130.0
offset_right = 120.0
offset_bottom = 130.0

[node name="Subtitle" type="Label" parent="VBox"]
layout_mode = 2
text = "Your station is in pieces. Put it back together."
horizontal_alignment = 1
theme_override_font_sizes/font_size = 13
modulate = Color(0.7, 0.75, 0.85, 1.0)

[node name="PlayButton" type="Button" parent="VBox" unique_id=264093592]
layout_mode = 2
text = "Play"

[node name="LevelSelectButton" type="Button" parent="VBox" unique_id=406645112]
layout_mode = 2
text = "Level Select"

[node name="ScoreboardButton" type="Button" parent="VBox" unique_id=1234567891]
layout_mode = 2
text = "Scoreboard"

[node name="ShopButton" type="Button" parent="VBox" unique_id=1234567890]
layout_mode = 2
text = "Shop"

[node name="SettingsButton" type="Button" parent="VBox" unique_id=1758634346]
layout_mode = 2
text = "Settings"

[node name="QuitButton" type="Button" parent="VBox" unique_id=565157653]
layout_mode = 2
text = "Quit"
```

(Note: `offset_top` changed from `-120.0` to `-130.0` and `offset_bottom` from `120.0` to `130.0` to give the VBox a little extra height for the new label.)

- [ ] **Step 2: Validate**

```bash
~/.local/share/nvim/mason/bin/gdformat . && timeout 30 godot --headless --check-only 2>&1 | grep -E "^ERROR|SCRIPT ERROR"
```
Expected: no ERROR lines, exit 124.

- [ ] **Step 3: Commit**

```bash
git add game/menu/main_menu.tscn
git commit -m "feat(menu): add story subtitle to main menu"
```
