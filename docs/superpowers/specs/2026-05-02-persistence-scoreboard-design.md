# Persistence & Scoreboard Design

**Date:** 2026-05-02  
**Status:** Approved

## Problem

`GameState` is memory-only — all progress (currency, unlocks, character, upgrades) resets on quit. There is also no scoreboard, so players have no record of their attempts or completion times.

## Goals

- Persist player progression between sessions
- Per-level scoreboard showing up to 20 attempts with completion times for wins and survival times for losses
- "Delete Save" and "Reset Scoreboard" buttons in settings (main menu only)
- Scoreboard accessible from main menu (level dropdown), level select (per-level), and win screen

---

## Architecture

### New Files

| File | Responsibility |
|------|---------------|
| `core/utils/save_manager.gd` | Static helper — all file I/O for both save files |
| `game/ui/scoreboard.tscn/gd` | Full-screen scoreboard scene with level dropdown and two sections |

### Modified Files

| File | Change |
|------|--------|
| `core/autoloads/game_state.gd` | Add `scoreboard: Dictionary`, `settings_from_main_menu: bool`; call SaveManager on state changes; load both files in `_ready()` |
| `game/gameplay/game.gd` | Add `_game_start_time: float`; record attempt on every game end |
| `game/menu/settings.gd/tscn` | Add "Delete Save" + "Reset Scoreboard" buttons (hidden when not from main menu) |
| `game/menu/main_menu.gd/tscn` | Add "Scoreboard" button; set `GameState.settings_from_main_menu = true` before navigating to settings |
| `game/menu/level_select.gd/tscn` | Add per-level "Scores" button |
| `game/menu/pause_menu.gd/tscn` | Set `GameState.settings_from_main_menu = false` before navigating to settings |
| `game/ui/win_screen.gd/tscn` | Add "View Scores" button and `scores_pressed` signal |

---

## Save Files

### `user://progression.json`

Holds all progression data. Deleted by "Delete Save" — does not touch scores.

```json
{
  "currency": 350,
  "current_character": "cat",
  "unlocked_levels": [0, 1],
  "unlocked_characters": ["penguin", "cat"],
  "purchased_abilities": ["double_jump"],
  "character_upgrades": {"penguin": {"move_speed": 1}}
}
```

**Saved after:** any purchase, unlock, character select, stat upgrade.

**On delete:** file removed, `GameState` progression fields reset to code defaults (currency=0, current_character="penguin", unlocked_levels=[0], etc.).

### `user://scores.json`

Holds per-level attempt history. Deleted by "Reset Scoreboard" — does not touch progression.

```json
{
  "0": [
    {"result": "WON", "time": 58.3, "ts": 1748000010},
    {"result": "LEFT_BEHIND", "time": 23.1, "ts": 1748000000}
  ],
  "1": []
}
```

**Fields per entry:**
- `result: String` — `"WON"`, `"DIED"`, `"DRIFTED"`, or `"LEFT_BEHIND"`
- `time: float` — elapsed seconds from gameplay start to end (timer starts when intro ends)
- `ts: int` — Unix timestamp; used to determine recency ("last 3 attempts")

**Capacity:** max 20 entries per level. When adding a 21st, the entry with the oldest `ts` is removed.

**On delete:** file removed, `GameState.scoreboard` cleared.

---

## SaveManager

`core/utils/save_manager.gd` — plain class (not autoload), all methods static.

```gdscript
class_name SaveManager

const SAVE_PATH: String = "user://progression.json"
const SCORES_PATH: String = "user://scores.json"

static func save_progression() -> void
static func load_progression() -> void   # no-op if file absent
static func delete_progression() -> void # delete file + reset GameState fields

static func save_scores() -> void
static func load_scores() -> void        # no-op if file absent
static func delete_scores() -> void      # delete file + clear GameState.scoreboard
```

`GameState._ready()` calls `load_progression()` then `load_scores()`.

---

## Scoreboard Data Model

### GameState additions

```gdscript
## level_id (as String key) → Array of attempt dicts {result, time, ts}
var scoreboard: Dictionary = {}
var settings_from_main_menu: bool = false
```

### Recording an attempt (game.gd)

- `_game_start_time: float` is set in `_on_jetpack_depleted()` (when gameplay begins)
- On every game end (win or loss), `_record_attempt(result)` is called:
  - Computes `elapsed = Time.get_unix_time_from_system() - _game_start_time`
  - Appends `{result: ..., time: elapsed, ts: unix_now}` to `GameState.scoreboard[str(level_id)]`
  - Trims to 20 entries (drop oldest by `ts`)
  - Calls `SaveManager.save_scores()`

### Sorting rules

The "All Attempts" section is sorted:
1. **Wins** first, sorted by `time` ascending (fastest = rank #1)
2. **Losses** after wins, sorted by `time` descending (longest survival = first among losses)

Rank = position in this sorted list (1-based).

---

## Scoreboard UI

### Scene: `game/ui/scoreboard.tscn`

Full-screen Control. Public API:

```gdscript
func open(level_id: int) -> void   # populates dropdown and renders lists
signal back_pressed                  # caller handles navigation
```

### Layout

```
[Level: Test Level ▼]          ← OptionButton, all levels listed

LAST 3 ATTEMPTS
──────────────────────────────
 #3  Win           0:58  ●     ← ● = "latest" marker (most recent ts)
 #4  Left Behind   0:45
 #1  Win           0:38

ALL ATTEMPTS
──────────────────────────────
 #1  Win           0:38
 #2  Win           0:52
 #3  Win           0:58  ●     ← same entry, same rank, highlighted again
 #4  Left Behind   0:45
 #5  Died          0:12
...

[Back]
```

- Time format: `mm:ss.t` where `t` is tenths of a second (e.g. `1:03.4` = 1 min 3.4 sec; `0:58.3` = 58.3 sec)
- "Latest" entry: the one with the highest `ts` across all entries for this level
- If the latest entry also appears in "All Attempts" (always true — only oldest is dropped when >20), it is highlighted in both sections
- "Last 3 Attempts": the 3 entries with the highest `ts` values, shown newest-first. If fewer than 3 entries exist, show all available. If no entries, show "No attempts yet."
- If `scoreboard` has no key for the selected level, treat it as an empty array (show "No attempts yet" in both sections)

### Access Points

| Entry point | Default level shown |
|-------------|-------------------|
| Main menu → "Scoreboard" button | `GameState.current_level` |
| Level select → "Scores" button per level | That level |
| Win screen → "View Scores" button | Just-completed level |

---

## Settings Screen Changes

Two new buttons, visible only when `GameState.settings_from_main_menu == true`:

**"Delete Save"**
- Shows a confirmation dialog: "This will delete all progression (currency, unlocks, upgrades). Scores are kept. Continue?"
- On confirm: `SaveManager.delete_progression()`; navigate back to main menu

**"Reset Scoreboard"**
- Shows a confirmation dialog: "This will delete all scoreboard history. Progression is kept. Continue?"
- On confirm: `SaveManager.delete_scores()`; stay on settings screen

**Navigation context tracking:**
- `main_menu.gd` sets `GameState.settings_from_main_menu = true` before `change_scene_to_file` to settings
- `pause_menu.gd` sets `GameState.settings_from_main_menu = false` before navigating to settings
- Settings reads this in `_ready()` to show/hide the buttons

---

## Out of Scope

- Cloud save / cross-device sync
- Leaderboard comparison across players
- Save file encryption or tamper detection
- Scoreboard filtering by result type
