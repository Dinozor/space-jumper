# Wall Jumper — TODO

## Settings / Options
- [x] Add settings screen accessible from the main menu
- [x] Volume toggle (music and SFX on/off)
- [x] Control remapping for all player actions (move_left, move_right, move_forward, move_back)

## UI / HUD
- [x] Scoreboard: per-level screen showing ~20 attempts; wins show completion time. Accessible from main menu, level select (per level), and win screen. Scoreboard data persisted in save file.
- [x] Win screen: replace GameOver with split WinScreen + LoseScreen scenes. Win shows "+X coins · Total: Y", Play Again, Next Level (disabled+tooltip if last level), Go to Shop, Main Menu. Lose shows context-aware button: "Try Again" on first attempt, "Keep Trying" on retries. Track attempts via GameState.attempt_count.
- [x] Add player health bar
- [x] Add progress bar — starts at 1/3; fills toward station; 0 = "left behind" loss
- [x] Level select must show levels loaded from `resources/levels/` via LevelLoader
- [x] Add "Back to Menu" button on the level select screen
- [x] Redesign shop as two tabbed screens: "Upgrades" (abilities in a grid) and "Characters" (character cards with stats + stat upgrade buttons); replace the single scrolling VBox with a proper grid layout
- [x] Show locked levels in level select — render all levels as buttons, but disable and gray out locked ones with a tooltip explaining how to unlock (e.g. "Beat Test Level to unlock")
- [x] Add pause menu — pressing Esc during gameplay pauses the game and shows a pause overlay with three options: Settings (opens the existing settings screen), Exit to Main Menu, and Resume

## Bugs
- [x] Character selection visual bug: selecting cat/bear in shop doesn't change player mesh (only stats). Fix: add mesh_scene to cat.tres/bear.tres, add mesh-swap in player.gd._ready().
- [ ] Boost bar not updating during intro and never hidden/shown based on jetpack ability ownership. Fix: update fuel in game.gd._process during intro; hide bar on game start if player lacks jetpack ability.
- [x] Debris contact sometimes fails to trigger player bounce — needs reliable single-fire collision detection
- [x] Debris can trigger player bounce multiple times per touch — each contact should fire once only
- [x] Player should be invincible before game start as now he can die before game even starts.
- [x] Level select only shows one level even though multiple `.tres` files exist in `resources/levels/` — investigate LevelLoader or level_select.gd to find why only one entry appears
- [x] Crash on level start: `Invalid call. Nonexistent function 'is_action_just_pressed' in base 'InputEventMouseMotion'` — `_unhandled_input` in game.gd and pause_menu.gd calls `event.is_action_just_pressed()` which is not implemented on mouse-motion events; replace with `Input.is_action_just_pressed()`

## Intro sequence
- [x] Player starts below the debris field, boosting upward toward the station with no player control
- [x] Show a 3-2-1 countdown in the HUD during the boost; control is locked until it hits 0
- [x] When countdown reaches 0 (boost runs out), player gains full control and gameplay begins

## Ending squence
- [x] Some levels might have a rope hangin from the station (cable). When reaching close enought proximity to the station, cinematic starts, player hooks onto cable and drags himslef into the station. Player wins. Note, that player player should become invincible to the object, or better object appear from withing the station and can not harm player.

## Physics reframe — "station flies away"

The story: the player isn't falling — the station is flying away. Everything in the debris
field drifts at the same rate, so platforms feel stable relative to the player. Bouncing is
the only way to close the gap. Different levels = different station escape speeds (slow
orbital drift vs fast fleeing ship).

- [x] Add `station_escape_speed` to `LevelData` (replaces the role of `fall_speed` for debris and player drift). This is the shared downward velocity applied to both the player and all debris every frame — the reference-frame equivalent of the station flying away.
- [x] Replace player's hardcoded `GRAVITY` constant with `station_escape_speed` read from the active level. Player drifts at this rate by default; bouncing is what lets them gain on the station. No hardcoded gravity values anywhere.
- [x] Debris base fall speed should equal `station_escape_speed` so debris feels stationary relative to the player in freefall. Player standing on a platform shouldn't slide off it vertically.
- [x] Add `drag` to `LevelData`: a 0–1 coefficient applied to the player's upward velocity each frame (`velocity.y *= 1.0 - drag * delta`). Explains in-world why a bounce doesn't carry the player forever — atmospheric resistance, debris-field drag, or weak gravitational pull of the escaping station. Different levels can feel floaty (low drag, deep space) or sluggish (high drag, dense debris cloud).
- [x] Win / left-behind thresholds in `LevelManager` should use distance-to-station rather than absolute Y so the system works when `station_escape_speed` varies across levels.
- [x] Progress bar shows distance-to-station (closes as player gains, opens as player falls behind), not the player's absolute Y height.
- [x] Tune `test_level`: set `station_escape_speed` and `drag` so standing still means losing, but skilled bouncing lets you close the gap.
- [x] Add a second level with a faster `station_escape_speed` to prove the per-level parameter changes the feel in a meaningful way.

## Gameplay mechanics
- [x] Cap max fall speed so player can catch the station
- [x] Debris should have varied falling speeds
- [x] Add more debris variety — need wall-type obstacles
- [x] Add huge debris chunk with a doorway the player must navigate through
- [x] Add jetpack boost intro: player starts with a burst, game begins when it runs out
- [x] Bounce direction should reflect off the contact surface — player bounces away from the object, not just straight up
- [x] Only dedicated hazard objects should deal damage — safe debris, walls, and doorways must not damage the player on contact (hitting a falling object is punishment enough)
- [x] **[HIGH PRIORITY]** Increase wall-bounce lateral impulse — current force is too weak; bouncing off the same wall twice in a row should require real effort and precise positioning

## Pickups
- [x] Health pickup
- [x] Boost pickup for sparse-debris situations

## Level design
- [x] Level scripted sections: LevelData can define PatternSections — lists of pre-placed objects at fixed Y positions, injected at startup before random fill
- [x] Checkpoint debris type: a stationary platform (gravity_scale = 0) that bounces the player, usable in PatternSections as a mid-level rest point
- [x] Add authored wave/pattern groups to the corridor spawner — instead of pure random fill, spawn curated formations (e.g. wall + two safe platforms + gap) so the corridor has breathing room and readable structure

## Tech / refactor
- [x] Refactor end-state strings to use an Enum
- [x] Audit `_process` with `if _emitted: return` — replace with `set_process(false)` where better
- [x] Make level resources auto-loadable from folder
- [x] Make first level loadable as resource too.
- [x] Create proper game stylebox/theme and apply it globaly. Do not configure it in code.

## Content / data
- [x] Define a spawn table resource — what objects can spawn, their weight/frequency, and at what difficulty thresholds they appear
- [x] Move all per-object tuning (fall speed, damage, size, etc.) into individual object resources instead of hardcoded script constants
- [x] Replace hardcoded spawner ratios (`HAZARD_RATIO`, `boost_spawn_ratio`, etc.) with lookups into the spawn table resource
- [x] **[HIGH PRIORITY]** Reduce debris spawn rates — current density makes the game unplayable; tune spawn table so the corridor has clear gaps and readable object spacing
- [x] Add a tag/type system to debris — each object carries zero or more tags (e.g. `shootable`, `sticky`, `icy`); tags affect bounce behaviour and interaction rules; `shootable` objects can be destroyed by projectiles and some may require multiple hits

## CI/CD
- [x] Set up pipeline; use butler to deploy to itch.io

## Economy / Progression
- [x] Completing a level rewards the player with a currency amount (stored in `GameState`)
- [x] Add an unlockables / shop menu accessible from the main menu where currency is spent on upgrades and character unlocks
- [x] Persist progress between sessions: save currency, unlocked levels/characters, purchased abilities, character upgrades, current character to disk (user://save.json). Load on startup. Add "Delete Save" button in settings (only accessible from main menu) that wipes the file and resets GameState to defaults.

## Upgrades & Abilities
- [x] Design a dynamic, data-driven ability system — abilities attach to the player as injectable resources/components; no hardcoded `if has_ability` branches in player code
- [x] Ability: double jump — grants one extra jump while airborne before landing again
- [x] Ability: jetpack — purchasable active upward thrust (distinct from the intro boost); has limited fuel that recharges
- [x] Ability: boost recharge — passive; slowly refills boost fuel after a cooldown of X seconds post-boost; upgradable to increase recharge rate (multiple upgrade tiers)
- [x] Ability: shooting — player fires projectiles that destroy `shootable`-tagged debris; pairs with the debris tag system
- [x] Ability: grappling gloves — reduces lateral bounce velocity after wall contact, making it easier to chain wall jumps
- [x] Ability: sticky boots — negates lateral bounce velocity entirely on wall contact; allows precise repeated wall jumps from the same surface

## Characters
- [x] Allow players to unlock alternate characters from the Kenney Cube Pets pack via the shop menu
- [x] Each character has a stat profile: `move_speed`, `jump_force`, `aerodynamics` (scales the drag coefficient applied to that character)
- [x] Character stats are individually upgradable via the upgrades menu
