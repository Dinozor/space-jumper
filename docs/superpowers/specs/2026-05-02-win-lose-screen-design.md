# Win / Lose Screen Redesign

**Date:** 2026-05-02  
**Status:** Approved

## Problem

The current `GameOver` scene handles both win and lose states with one shared layout. It shows only a reason label, a "Restart" button, and a "Main Menu" button — with no coin reward display, no navigation to the next level or shop, and context-insensitive button labels.

## Goals

- On win: show coins earned + total balance, offer Next Level / Go to Shop / Play Again / Main Menu
- On lose: show a contextual retry label (Try Again vs Keep Trying based on attempt count)
- Remove the generic "Restart" label entirely from both screens

---

## Scene Architecture

Replace `game/ui/game_over.tscn` and `game/ui/game_over.gd` with two purpose-built scenes:

### `game/ui/win_screen.tscn / win_screen.gd`

Nodes:
- `Panel`
  - `ResultLabel` — "You reached the station!"
  - `CoinsLabel` — "+100 coins · Total: 350"
  - `PlayAgainButton` — "Play Again"
  - `NextLevelButton` — "Next Level" (disabled + tooltip if no next level)
  - `ShopButton` — "Go to Shop"
  - `MenuButton` — "Main Menu"

Public API:
```gdscript
func show_result(earned: int, total: int) -> void
```

### `game/ui/lose_screen.tscn / lose_screen.gd`

Nodes:
- `Panel`
  - `ResultLabel` — contextual message (DIED / DRIFTED / LEFT_BEHIND)
  - `RetryButton` — "Try Again" (attempt 1) or "Keep Trying" (attempt 2+)
  - `MenuButton` — "Main Menu"

Public API:
```gdscript
func show_result(reason: Game.EndState, attempt_count: int) -> void
```

---

## Data Flow

### Coins display

`game.gd` calls `_award_currency()` before showing the win screen. At that point `GameState.currency` already includes the reward. `win_screen.show_result(level_data.level_reward, GameState.currency)` receives both values.

### Next Level availability

`win_screen.gd` checks whether `GameState.current_level + 1` is in `GameState.unlocked_levels`. Since `_award_currency()` calls `unlock_next_level()` before the screen shows, "Next Level" will normally be enabled after a win. It is disabled only when the player has completed the last available level.

Disabled tooltip text: `"No more levels unlocked yet"`

### Attempt tracking

`GameState` gains a new field: `attempt_count: int = 0`

- Incremented in `game.gd._ready()` each time the level scene loads
- Read by `lose_screen.gd` to pick the retry label:
  - `attempt_count == 1` → "Try Again"
  - `attempt_count > 1` → "Keep Trying"
- Reset to `0` automatically in `game.gd._ready()` when `GameState.current_level` differs from a new `GameState.last_attempt_level_id` field (tracks which level the attempts belong to). This covers Main Menu → New Level, Level Select → different level, and Next Level navigation — without needing manual resets at every exit point.

### Button actions

| Button | Action |
|--------|--------|
| Play Again | `get_tree().reload_current_scene()` |
| Try Again / Keep Trying | `get_tree().reload_current_scene()` |
| Next Level | `GameState.current_level += 1` then `reload_current_scene()` |
| Go to Shop | `change_scene_to_file("res://game/menu/shop.tscn")` |
| Main Menu | Reset `attempt_count = 0`, `change_scene_to_file("res://game/menu/main_menu.tscn")` |

---

## Changes to game.gd

- Replace `@onready var _game_over: GameOver` with two refs: `_win_screen: WinScreen` and `_lose_screen: LoseScreen`
- Hide both in `_ready()`
- `_on_station_reached()` and `_finish_cable_win()` call `_win_screen.show_result(...)`
- `_end_game()` calls `_lose_screen.show_result(reason, GameState.attempt_count)`
- Connect signals: `restart_pressed` and `menu_pressed` from both screens

---

## Out of Scope

- Animated coin counter
- High score / best time tracking
- Level completion stars or rating
