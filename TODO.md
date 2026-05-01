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

## Intro sequence
- [x] Player starts below the debris field, boosting upward toward the station with no player control
- [x] Show a 3-2-1 countdown in the HUD during the boost; control is locked until it hits 0
- [x] When countdown reaches 0 (boost runs out), player gains full control and gameplay begins

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

## Tech / refactor
- [x] Refactor end-state strings to use an Enum
- [x] Audit `_process` with `if _emitted: return` — replace with `set_process(false)` where better
- [x] Make level resources auto-loadable from folder
- [x] Make first level loadable as resource too.

## Content / data
- [x] Define a spawn table resource — what objects can spawn, their weight/frequency, and at what difficulty thresholds they appear
- [x] Move all per-object tuning (fall speed, damage, size, etc.) into individual object resources instead of hardcoded script constants
- [x] Replace hardcoded spawner ratios (`HAZARD_RATIO`, `boost_spawn_ratio`, etc.) with lookups into the spawn table resource

## CI/CD
- [x] Set up pipeline; use butler to deploy to itch.io
