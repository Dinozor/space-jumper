# Win / Lose Screen Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the shared `GameOver` scene with a `WinScreen` (coins earned, Play Again, Next Level, Go to Shop, Main Menu) and a `LoseScreen` (contextual Try Again / Keep Trying button).

**Architecture:** Delete `game_over.tscn/gd`. Create `win_screen.tscn/gd` and `lose_screen.tscn/gd` as `CanvasLayer` nodes. Add `attempt_count` and `last_attempt_level_id` to `GameState`. Wire both screens into `game.tscn` and `game.gd`.

**Tech Stack:** Godot 4 GDScript, Godot scene format (.tscn). Validate with `gdformat` + `timeout 30 godot --headless --check-only`.

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `core/autoloads/game_state.gd` | Add `attempt_count` + `last_attempt_level_id` fields |
| Create | `game/ui/lose_screen.gd` | LoseScreen class: contextual retry label, signals |
| Create | `game/ui/lose_screen.tscn` | LoseScreen scene: ResultLabel, RetryButton, MenuButton |
| Create | `game/ui/win_screen.gd` | WinScreen class: coins display, Next Level availability, signals |
| Create | `game/ui/win_screen.tscn` | WinScreen scene: all five buttons + coins label + hint label |
| Modify | `game/gameplay/game.gd` | Swap GameOver → WinScreen + LoseScreen; attempt tracking |
| Modify | `game/gameplay/game.tscn` | Replace GameOver node with WinScreen + LoseScreen nodes |
| Delete | `game/ui/game_over.gd` | No longer needed |
| Delete | `game/ui/game_over.tscn` | No longer needed |

---

## Task 1: Add attempt tracking fields to GameState

**Files:**
- Modify: `core/autoloads/game_state.gd`

- [ ] **Step 1: Open and read the file**

  Read `core/autoloads/game_state.gd`. Locate the block of `var` declarations at the top (lines ~8–18).

- [ ] **Step 2: Add the two new fields after `current_level`**

  Insert directly after `var current_level: int = 0`:

  ```gdscript
  var attempt_count: int = 0
  var last_attempt_level_id: int = -1
  ```

  The var block should now read:
  ```gdscript
  var score: int = 0
  var lives: int = 3
  var current_level: int = 0
  var attempt_count: int = 0
  var last_attempt_level_id: int = -1
  var unlocked_levels: Array[int] = [0]
  ```

- [ ] **Step 3: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add core/autoloads/game_state.gd
  git commit -m "feat(ui): add attempt_count and last_attempt_level_id to GameState"
  ```

---

## Task 2: Create lose_screen.gd

**Files:**
- Create: `game/ui/lose_screen.gd`

- [ ] **Step 1: Create the file**

  Create `game/ui/lose_screen.gd` with this exact content:

  ```gdscript
  class_name LoseScreen
  extends CanvasLayer

  ## Lose screen: shows failure reason and a contextual retry button.

  signal retry_pressed
  signal menu_pressed

  var _reason_messages: Dictionary

  @onready var _result_label: Label = $Panel/ResultLabel
  @onready var _retry_button: Button = $Panel/RetryButton
  @onready var _menu_button: Button = $Panel/MenuButton


  func _ready() -> void:
  	_reason_messages = {
  		Game.EndState.DIED: "You were destroyed!",
  		Game.EndState.DRIFTED: "You drifted away!",
  		Game.EndState.LEFT_BEHIND: "You were left behind!",
  	}
  	_retry_button.pressed.connect(_on_retry_pressed)
  	_menu_button.pressed.connect(_on_menu_pressed)


  func _on_retry_pressed() -> void:
  	AudioManager.play_button()
  	retry_pressed.emit()


  func _on_menu_pressed() -> void:
  	AudioManager.play_button()
  	menu_pressed.emit()


  func show_result(reason: Game.EndState, attempt_count: int) -> void:
  	_result_label.text = _reason_messages.get(reason, "Game Over")
  	_retry_button.text = "Try Again" if attempt_count <= 1 else "Keep Trying"
  	show()
  ```

- [ ] **Step 2: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors (note: `Game` class is defined in `game/gameplay/game.gd` — parser resolves it).

- [ ] **Step 3: Commit**

  ```bash
  git add game/ui/lose_screen.gd
  git commit -m "feat(ui): add LoseScreen script with contextual retry label"
  ```

---

## Task 3: Create lose_screen.tscn

**Files:**
- Create: `game/ui/lose_screen.tscn`

- [ ] **Step 1: Create the scene file**

  Create `game/ui/lose_screen.tscn` with this exact content:

  ```
  [gd_scene format=3 uid="uid://closescrntsc1"]

  [ext_resource type="Script" uid="uid://closescrngd01" path="res://game/ui/lose_screen.gd" id="Script_1"]

  [node name="LoseScreen" type="CanvasLayer"]
  script = ExtResource("Script_1")

  [node name="Panel" type="Panel" parent="." unique_id=100000001]
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -220.0
  offset_top = -120.0
  offset_right = 220.0
  offset_bottom = 120.0

  [node name="ResultLabel" type="Label" parent="Panel" unique_id=100000002]
  layout_mode = 0
  anchor_right = 1.0
  offset_left = 10.0
  offset_top = 20.0
  offset_right = -10.0
  offset_bottom = 70.0
  text = "Game Over"
  horizontal_alignment = 1
  theme_override_font_sizes/font_size = 28

  [node name="RetryButton" type="Button" parent="Panel" unique_id=100000003]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = -20.0
  offset_right = 100.0
  offset_bottom = 18.0
  text = "Try Again"
  theme_override_font_sizes/font_size = 18

  [node name="MenuButton" type="Button" parent="Panel" unique_id=100000004]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = 28.0
  offset_right = 100.0
  offset_bottom = 66.0
  text = "Main Menu"
  theme_override_font_sizes/font_size = 18
  ```

- [ ] **Step 2: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git add game/ui/lose_screen.tscn
  git commit -m "feat(ui): add LoseScreen scene"
  ```

---

## Task 4: Create win_screen.gd

**Files:**
- Create: `game/ui/win_screen.gd`

- [ ] **Step 1: Create the file**

  Create `game/ui/win_screen.gd` with this exact content:

  ```gdscript
  class_name WinScreen
  extends CanvasLayer

  ## Win screen: shows coins earned, offers navigation to next level, shop, replay, or menu.

  signal play_again_pressed
  signal next_level_pressed
  signal shop_pressed
  signal menu_pressed

  @onready var _result_label: Label = $Panel/ResultLabel
  @onready var _coins_label: Label = $Panel/CoinsLabel
  @onready var _play_again_button: Button = $Panel/PlayAgainButton
  @onready var _next_level_button: Button = $Panel/NextLevelButton
  @onready var _next_level_hint: Label = $Panel/NextLevelHint
  @onready var _shop_button: Button = $Panel/ShopButton
  @onready var _menu_button: Button = $Panel/MenuButton


  func _ready() -> void:
  	_play_again_button.pressed.connect(_on_play_again_pressed)
  	_next_level_button.pressed.connect(_on_next_level_pressed)
  	_shop_button.pressed.connect(_on_shop_pressed)
  	_menu_button.pressed.connect(_on_menu_pressed)


  func _on_play_again_pressed() -> void:
  	AudioManager.play_button()
  	play_again_pressed.emit()


  func _on_next_level_pressed() -> void:
  	AudioManager.play_button()
  	next_level_pressed.emit()


  func _on_shop_pressed() -> void:
  	AudioManager.play_button()
  	shop_pressed.emit()


  func _on_menu_pressed() -> void:
  	AudioManager.play_button()
  	menu_pressed.emit()


  func show_result(earned: int, total: int) -> void:
  	_result_label.text = "You reached the station!"
  	_coins_label.text = "+%d coins  ·  Total: %d" % [earned, total]
  	var next_id: int = GameState.current_level + 1
  	var has_next: bool = next_id in GameState.unlocked_levels
  	_next_level_button.disabled = not has_next
  	_next_level_hint.visible = not has_next
  	show()
  ```

- [ ] **Step 2: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git add game/ui/win_screen.gd
  git commit -m "feat(ui): add WinScreen script with coins display and Next Level gating"
  ```

---

## Task 5: Create win_screen.tscn

**Files:**
- Create: `game/ui/win_screen.tscn`

Panel is 440×380 centered. Buttons are centered horizontally (anchor_left=0.5, anchor_right=0.5) and positioned relative to the panel center (y=190).

- [ ] **Step 1: Create the scene file**

  Create `game/ui/win_screen.tscn` with this exact content:

  ```
  [gd_scene format=3 uid="uid://cwinscrntscn1"]

  [ext_resource type="Script" uid="uid://cwinscrngd001" path="res://game/ui/win_screen.gd" id="Script_1"]

  [node name="WinScreen" type="CanvasLayer"]
  script = ExtResource("Script_1")

  [node name="Panel" type="Panel" parent="." unique_id=200000001]
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -220.0
  offset_top = -190.0
  offset_right = 220.0
  offset_bottom = 190.0

  [node name="ResultLabel" type="Label" parent="Panel" unique_id=200000002]
  layout_mode = 0
  anchor_right = 1.0
  offset_left = 10.0
  offset_top = 15.0
  offset_right = -10.0
  offset_bottom = 65.0
  text = "You reached the station!"
  horizontal_alignment = 1
  theme_override_font_sizes/font_size = 26

  [node name="CoinsLabel" type="Label" parent="Panel" unique_id=200000003]
  layout_mode = 0
  anchor_right = 1.0
  offset_left = 10.0
  offset_top = 70.0
  offset_right = -10.0
  offset_bottom = 100.0
  text = "+0 coins  ·  Total: 0"
  horizontal_alignment = 1
  theme_override_font_sizes/font_size = 18

  [node name="PlayAgainButton" type="Button" parent="Panel" unique_id=200000004]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = -80.0
  offset_right = 100.0
  offset_bottom = -42.0
  text = "Play Again"
  theme_override_font_sizes/font_size = 18

  [node name="NextLevelButton" type="Button" parent="Panel" unique_id=200000005]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = -32.0
  offset_right = 100.0
  offset_bottom = 6.0
  text = "Next Level"
  theme_override_font_sizes/font_size = 18

  [node name="NextLevelHint" type="Label" parent="Panel" unique_id=200000006]
  layout_mode = 0
  anchor_right = 1.0
  offset_left = 10.0
  offset_top = 202.0
  offset_right = -10.0
  offset_bottom = 220.0
  text = "No more levels available"
  horizontal_alignment = 1
  theme_override_font_sizes/font_size = 13
  modulate = Color(0.7, 0.7, 0.7, 1)

  [node name="ShopButton" type="Button" parent="Panel" unique_id=200000007]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = 38.0
  offset_right = 100.0
  offset_bottom = 76.0
  text = "Go to Shop"
  theme_override_font_sizes/font_size = 18

  [node name="MenuButton" type="Button" parent="Panel" unique_id=200000008]
  layout_mode = 0
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -100.0
  offset_top = 85.0
  offset_right = 100.0
  offset_bottom = 123.0
  text = "Main Menu"
  theme_override_font_sizes/font_size = 18
  ```

- [ ] **Step 2: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git add game/ui/win_screen.tscn
  git commit -m "feat(ui): add WinScreen scene"
  ```

---

## Task 6: Update game.gd

**Files:**
- Modify: `game/gameplay/game.gd`

- [ ] **Step 1: Replace the `_game_over` onready with two new refs**

  Find this line (~line 23):
  ```gdscript
  @onready var _game_over: GameOver = $GameOver
  ```

  Replace with:
  ```gdscript
  @onready var _win_screen: WinScreen = $WinScreen
  @onready var _lose_screen: LoseScreen = $LoseScreen
  ```

- [ ] **Step 2: Replace the GameOver wiring block in `_ready()`**

  Find these three lines in `_ready()`:
  ```gdscript
  	_game_over.restart_pressed.connect(_restart)
  	_game_over.menu_pressed.connect(_go_to_menu)
  	_game_over.hide()
  ```

  Replace with:
  ```gdscript
  	if GameState.last_attempt_level_id != GameState.current_level:
  		GameState.attempt_count = 0
  		GameState.last_attempt_level_id = GameState.current_level
  	GameState.attempt_count += 1
  	_win_screen.play_again_pressed.connect(_restart)
  	_win_screen.next_level_pressed.connect(_go_to_next_level)
  	_win_screen.shop_pressed.connect(_go_to_shop)
  	_win_screen.menu_pressed.connect(_go_to_menu)
  	_lose_screen.retry_pressed.connect(_restart)
  	_lose_screen.menu_pressed.connect(_go_to_menu)
  	_win_screen.hide()
  	_lose_screen.hide()
  ```

- [ ] **Step 3: Update `_on_station_reached()` to call WinScreen**

  Find:
  ```gdscript
  	_game_over.show_result(EndState.WON)
  ```
  inside `_on_station_reached()` (there is one occurrence here).

  Replace with:
  ```gdscript
  	_win_screen.show_result(level_data.level_reward if level_data != null else 0, GameState.currency)
  ```

- [ ] **Step 4: Update `_finish_cable_win()` to call WinScreen**

  Find:
  ```gdscript
  	_game_over.show_result(EndState.WON)
  ```
  inside `_finish_cable_win()`.

  Replace with:
  ```gdscript
  	_win_screen.show_result(level_data.level_reward if level_data != null else 0, GameState.currency)
  ```

- [ ] **Step 5: Update `_end_game()` to call LoseScreen**

  Find:
  ```gdscript
  	_game_over.show_result(reason)
  ```
  inside `_end_game()`.

  Replace with:
  ```gdscript
  	_lose_screen.show_result(reason, GameState.attempt_count)
  ```

- [ ] **Step 6: Update `_go_to_menu()` to reset attempt tracking**

  Find:
  ```gdscript
  func _go_to_menu() -> void:
  	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
  ```

  Replace with:
  ```gdscript
  func _go_to_menu() -> void:
  	GameState.last_attempt_level_id = -1
  	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
  ```

- [ ] **Step 7: Add two new navigation methods at the end of the file**

  Append after `_go_to_menu()`:
  ```gdscript


  func _go_to_next_level() -> void:
  	GameState.current_level += 1
  	get_tree().reload_current_scene()


  func _go_to_shop() -> void:
  	GameState.last_attempt_level_id = -1
  	get_tree().change_scene_to_file("res://game/menu/shop.tscn")
  ```

- [ ] **Step 8: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors. If you see `Identifier 'GameOver' not found`, that's expected and will be resolved in Task 7 when the tscn is updated.

- [ ] **Step 9: Commit**

  ```bash
  git add game/gameplay/game.gd
  git commit -m "feat(ui): wire WinScreen and LoseScreen into game.gd"
  ```

---

## Task 7: Update game.tscn

**Files:**
- Modify: `game/gameplay/game.tscn`

- [ ] **Step 1: Replace the GameOver ext_resource with WinScreen + LoseScreen references**

  Find this line near the top of the file:
  ```
  [ext_resource type="PackedScene" uid="uid://dp4g5kwtgxq0d" path="res://game/ui/game_over.tscn" id="Scene_GameOver"]
  ```

  Replace with:
  ```
  [ext_resource type="PackedScene" uid="uid://cwinscrntscn1" path="res://game/ui/win_screen.tscn" id="Scene_WinScreen"]
  [ext_resource type="PackedScene" uid="uid://closescrntsc1" path="res://game/ui/lose_screen.tscn" id="Scene_LoseScreen"]
  ```

- [ ] **Step 2: Replace the GameOver node with WinScreen + LoseScreen nodes**

  Find:
  ```
  [node name="GameOver" parent="." unique_id=1351267110 instance=ExtResource("Scene_GameOver")]
  ```

  Replace with:
  ```
  [node name="WinScreen" parent="." unique_id=300000001 instance=ExtResource("Scene_WinScreen")]

  [node name="LoseScreen" parent="." unique_id=300000002 instance=ExtResource("Scene_LoseScreen")]
  ```

- [ ] **Step 3: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add game/gameplay/game.tscn
  git commit -m "feat(ui): replace GameOver node with WinScreen and LoseScreen in game.tscn"
  ```

---

## Task 8: Delete game_over files

**Files:**
- Delete: `game/ui/game_over.gd`
- Delete: `game/ui/game_over.tscn`

- [ ] **Step 1: Delete both files**

  ```bash
  git rm game/ui/game_over.gd game/ui/game_over.tscn
  ```

- [ ] **Step 2: Validate**

  ```bash
  ~/.local/share/nvim/mason/bin/gdformat .
  timeout 30 godot --headless --check-only
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git commit -m "refactor(ui): remove obsolete GameOver scene and script"
  ```

---

## Post-implementation checklist

- [ ] Run the game with `godot --main-scene game/gameplay/game.tscn` and verify:
  - Win path (reach the station): win screen shows "+X coins · Total: Y", Play Again works, Go to Shop works, Main Menu works, Next Level is enabled (if a next level exists) or disabled with hint
  - Lose path (fall behind / drift / die): "Try Again" on first attempt, "Keep Trying" on second+
  - Retrying after win resets correctly
  - Going to menu after a loss resets attempt count (next play shows "Try Again" again)
