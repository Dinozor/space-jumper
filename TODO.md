# Wall Jumper — TODO

## UI / HUD
- [x] Add player health bar
- [x] Add progress bar — starts at 1/3; fills toward station; 0 = "left behind" loss

## Bugs
- [ ] Debris contact sometimes fails to trigger player bounce — needs reliable single-fire collision detection
- [ ] Debris can trigger player bounce multiple times per touch — each contact should fire once only

## Gameplay mechanics
- [x] Cap max fall speed so player can catch the station
- [x] Debris should have varied falling speeds
- [x] Add more debris variety — need wall-type obstacles
- [x] Add huge debris chunk with a doorway the player must navigate through
- [x] Add jetpack boost intro: player starts with a burst, game begins when it runs out
- [ ] Bounce direction should reflect off the contact surface — player bounces away from the object, not just straight up

## Pickups
- [x] Health pickup
- [x] Boost pickup for sparse-debris situations

## Tech / refactor
- [x] Refactor end-state strings to use an Enum
- [x] Audit `_process` with `if _emitted: return` — replace with `set_process(false)` where better
- [x] Make level resources auto-loadable from folder

## Content / data
- [ ] Define a spawn table resource — what objects can spawn, their weight/frequency, and at what difficulty thresholds they appear
- [ ] Move all per-object tuning (fall speed, damage, size, etc.) into individual object resources instead of hardcoded script constants
- [ ] Replace hardcoded spawner ratios (`HAZARD_RATIO`, `boost_spawn_ratio`, etc.) with lookups into the spawn table resource

## CI/CD
- [x] Set up pipeline; use butler to deploy to itch.io
