# Wall Jumper — TODO

## Settings / Options
- [x] Add settings screen accessible from the main menu
- [x] Volume toggle (music and SFX on/off)
- [x] Control remapping for all player actions (move_left, move_right, move_forward, move_back)

## UI / HUD
- [x] Add player health bar
- [x] Add progress bar — starts at 1/3; fills toward station; 0 = "left behind" loss
- [x] Level select must show levels loaded from `resources/levels/` via LevelLoader
- [x] Add "Back to Menu" button on the level select screen

## Bugs
- [x] Debris contact sometimes fails to trigger player bounce — needs reliable single-fire collision detection
- [x] Debris can trigger player bounce multiple times per touch — each contact should fire once only
- [x] Player should be invincible before game start as now he can die before game even starts.

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
- [ ] Replace player's hardcoded `GRAVITY` constant with `station_escape_speed` read from the active level. Player drifts at this rate by default; bouncing is what lets them gain on the station. No hardcoded gravity values anywhere.
- [ ] Debris base fall speed should equal `station_escape_speed` so debris feels stationary relative to the player in freefall. Player standing on a platform shouldn't slide off it vertically.
- [ ] Add `drag` to `LevelData`: a 0–1 coefficient applied to the player's upward velocity each frame (`velocity.y *= 1.0 - drag * delta`). Explains in-world why a bounce doesn't carry the player forever — atmospheric resistance, debris-field drag, or weak gravitational pull of the escaping station. Different levels can feel floaty (low drag, deep space) or sluggish (high drag, dense debris cloud).
- [ ] Win / left-behind thresholds in `LevelManager` should use distance-to-station rather than absolute Y so the system works when `station_escape_speed` varies across levels.
- [ ] Progress bar shows distance-to-station (closes as player gains, opens as player falls behind), not the player's absolute Y height.
- [ ] Tune `test_level`: set `station_escape_speed` and `drag` so standing still means losing, but skilled bouncing lets you close the gap.
- [ ] Add a second level with a faster `station_escape_speed` to prove the per-level parameter changes the feel in a meaningful way.

## Gameplay mechanics
- [x] Cap max fall speed so player can catch the station
- [x] Debris should have varied falling speeds
- [x] Add more debris variety — need wall-type obstacles
- [x] Add huge debris chunk with a doorway the player must navigate through
- [x] Add jetpack boost intro: player starts with a burst, game begins when it runs out
- [x] Bounce direction should reflect off the contact surface — player bounces away from the object, not just straight up

## Pickups
- [x] Health pickup
- [x] Boost pickup for sparse-debris situations

## Level design
- [x] Level scripted sections: LevelData can define PatternSections — lists of pre-placed objects at fixed Y positions, injected at startup before random fill
- [x] Checkpoint debris type: a stationary platform (gravity_scale = 0) that bounces the player, usable in PatternSections as a mid-level rest point

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

## CI/CD
- [x] Set up pipeline; use butler to deploy to itch.io
