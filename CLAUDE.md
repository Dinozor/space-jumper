# Wall Jumper — Claude Code Project Guide

## Game Overview

**Genre:** 3D endless arcade / survival  
**Engine:** Godot 4 (latest stable)  
**Export target:** Web (HTML5)  
**Visual style:** 3D using Kenney assets

### Story
The player has fallen out of a space station along with a torrent of other debris. To survive,
they must jump between the falling objects to climb back up to the space station before they
drift too far away or fall too far behind.

### Core Loop
- The player and a stream of objects fall together in a vertical tube-shaped path
- Player can move **forward, backward, left, right** only (no direct up/down control)
- **Touch an object → bounce/jump off it** upward toward the space station
- Miss too many jumps → drift sideways out of the fall corridor → **lose (drifted away)**
- Jump too slowly or wait too long → fall too far below the space station → **lose (left behind)**
- Reach the space station at the top → **win the level**

### Objects in the fall corridor
| Type | Behaviour |
|------|-----------|
| Safe debris | Bounce off, gain height |
| Hazard debris | Damages player on contact, still bounceable |
| Boss objects | Special encounter, must be defeated to pass |

### Progression
- Multiple levels, each with a different debris theme and space environment
- Unlockable levels and cosmetics
- Boss encounters gating progress between level sets

---

## Project Structure

The project uses a **feature-folder** layout. Scenes and their attached scripts always live
together in the same folder — never separated into a top-level `scenes/` or `scripts/` split.
Pure logic with no scene dependency lives in `core/`. Imported art lives in `assets/`.

```
wall_jumper/
├── CLAUDE.md                  ← this file
├── project.godot
├── icon.svg
│
├── core/                      ← pure GDScript, no scene dependency
│   ├── autoloads/             ← singletons registered in Project Settings
│   │   ├── game_state.gd      ← score, lives, unlocks, current level
│   │   └── audio_manager.gd   ← music + sfx playback
│   ├── models/                ← RefCounted data classes (no Node inheritance)
│   │   ├── level_data.gd      ← LevelData resource class definition
│   │   └── player_stats.gd    ← runtime player state (health, score, etc.)
│   └── utils/                 ← stateless helper functions
│       ├── math_utils.gd
│       └── level_loader.gd    ← scans resources/levels/ and returns sorted LevelData array
│
├── game/                      ← everything that is a Godot node (scene + script together)
│   ├── main/
│   │   └── main.tscn          ← bootstraps the game, loads correct scene
│   ├── menu/
│   │   ├── main_menu.tscn
│   │   ├── main_menu.gd
│   │   ├── level_select.tscn
│   │   └── level_select.gd
│   ├── gameplay/
│   │   ├── game.tscn          ← root scene for a running level
│   │   ├── game.gd
│   │   ├── fall_corridor.tscn ← the tube the player falls inside
│   │   └── fall_corridor.gd
│   ├── player/
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── objects/               ← falling debris and interactive objects
│   │   ├── debris_safe.tscn
│   │   ├── debris_safe.gd
│   │   ├── debris_hazard.tscn
│   │   ├── debris_hazard.gd
│   │   ├── debris_wall.tscn
│   │   ├── debris_wall.gd     ← blocks one corridor half; player must find the open side
│   │   ├── debris_doorway.tscn
│   │   ├── debris_doorway.gd  ← huge slab with a randomised gap; player navigates through
│   │   ├── pickup_health.tscn
│   │   ├── pickup_health.gd
│   │   ├── pickup_boost.tscn
│   │   ├── pickup_boost.gd
│   │   ├── boss_base.tscn
│   │   └── boss_base.gd
│   ├── systems/               ← manager nodes with no visual, attached to Game
│   │   ├── corridor_spawner.gd
│   │   ├── drift_tracker.gd
│   │   ├── level_manager.gd
│   │   └── pickup_spawner.gd  ← drops health/boost pickups above the player on a timer
│   └── ui/
│       ├── hud.tscn
│       ├── hud.gd
│       ├── game_over.tscn
│       └── game_over.gd
│
├── resources/                 ← .tres / .res data files (instances of core/models/)
│   └── levels/
│       └── test_level.tres    ← only level so far; add more here (auto-loaded by LevelLoader)
│
├── config/                    ← project-level tuning tables and settings
│   └── gameplay_config.tres
│
└── assets/
	└── kenney/                ← copied from external source, read-only from code
		├── characters/
		├── environment/
		├── objects/
		└── ui/
```

### Why this layout

| Folder | Rule |
|--------|------|
| `core/` | No `Node` subclasses. No `@onready`. No scene paths. Testable in isolation. |
| `game/` | Every `.tscn` lives next to its `.gd`. Subfolders are features, not file types. |
| `resources/` | Only `.tres`/`.res` data files. No code here. |
| `config/` | Tuning data readable by designers without touching scripts. |
| `assets/` | Never written to at runtime. Paths only referenced via `@export` or constants. |

---

## Architecture Rules

- **Scenes are self-contained.** No scene directly accesses the internals of another scene.
- **Communicate via signals**, not direct `get_node()` calls across scene boundaries.
- **Singletons (autoloads)** only for truly global state: `GameState`, `AudioManager`.
  Register them in Project Settings → Autoload, pointing to `core/autoloads/`.
- **Groups** for cross-tree lookups: `"player"`, `"debris"`, `"main_camera"`.
- **`core/models/`** classes are pure `RefCounted` or `Resource` — never inherit `Node`.
- **`game/systems/`** nodes attach to `Game` as children and coordinate via signals.
- The **corridor** is the world. The space station moves toward the player (or player falls
  away from it) — never move the station, move everything else.

---

## Code Style

Follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) strictly. Key rules summarised:

### Naming
```gdscript
# Classes and nodes: PascalCase
class_name DebrisHazard

# Functions and variables: snake_case
var jump_force: float = 800.0
func apply_jump_force() -> void:

# Constants: SCREAMING_SNAKE_CASE
const MAX_DRIFT_DISTANCE: float = 12.0

# Signals: snake_case, past tense verb
signal player_jumped
signal debris_destroyed(points: int)

# Enums: PascalCase name, SCREAMING_SNAKE_CASE values
enum DebrisType { SAFE, HAZARD, BOSS }

# Private members: prefix with underscore
var _current_health: int = 3
func _apply_damage(amount: int) -> void:
```

### File layout order (top to bottom)
```gdscript
class_name MyClass
extends Node3D

## Doc comment describing what this script does.

# Signals
signal something_happened

# Enums
enum State { IDLE, FALLING, JUMPING }

# Constants
const SPEED: float = 10.0

# @export variables
@export var jump_force: float = 800.0

# Public variables
var current_state: State = State.IDLE

# Private variables
var _timer: float = 0.0

# @onready variables (last, just before _ready)
@onready var _mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


# Public methods before private methods
func do_something() -> void:
	pass


func _private_helper() -> void:
	pass
```

### Types
- **Always** use static typing. Every variable, parameter, and return type must be typed.
- Use `@export` for any value a designer might want to tune.
- Never use `var x = something` — always `var x: Type = something`.

### Functions
- Max **40 lines** per function. If longer, extract a helper.
- One blank line between functions, two blank lines before the first method after properties.
- Use `return` early to avoid deep nesting (guard clauses).

### Comments
- Use `##` doc comments on class definitions and public functions.
- Use `#` inline for *why*, not *what* — the code should explain what.
- No commented-out dead code in commits.

### Misc
- No magic numbers — give everything a named constant.
- Prefer `Vector3.ZERO`, `Color.WHITE` etc. over `Vector3(0,0,0)`.
- Use `push_error()` / `push_warning()` instead of `print()` for diagnostic output.
- `assert()` for invariants that must always hold in debug.

---

## Git Workflow

### Setup
```bash
git init
git add .
git commit -m "chore: initial project structure"
```

### Commit convention — Conventional Commits 1.0.0

Format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types used in this project:**

| Type | When to use |
|------|-------------|
| `feat` | New gameplay feature, new scene, new mechanic |
| `fix` | Bug fix in script or scene |
| `refactor` | Code restructure with no behaviour change |
| `style` | Formatting, naming — no logic change |
| `assets` | Adding or updating Kenney assets |
| `level` | New or edited level data (.tres) |
| `docs` | CLAUDE.md or other documentation |
| `chore` | Project settings, export config, dependencies |
| `perf` | Performance improvement |
| `test` | Adding tests or validation scripts |
| `revert` | Reverting a previous commit |

**Scopes** (optional, use when helpful):

`player`, `debris`, `corridor`, `ui`, `menu`, `audio`, `camera`, `boss`, `hud`

**Examples:**
```
feat(player): add lateral drift detection and out-of-bounds loss condition
fix(corridor): debris spawner not culling objects below camera
assets(environment): add kenney space kit skybox and platform meshes
level: add level_02 with asteroid debris theme
refactor(player): extract jump logic into dedicated _handle_jump method
docs: update asset manifest with new kenney character paths
chore: configure html5 export with COOP/COEP headers
```

### When to commit
- After every meaningful, working change — not after every line
- **Never commit broken or erroring code**
- Run `timeout 30 godot --headless --check-only` before every commit (see Validation below)
- One logical change per commit — if you can't describe it in one line, split it

---

## Godot Validation

Before every commit, run both steps in order:

```bash
# 1. Format all GDScript files
~/.local/share/nvim/mason/bin/gdformat .

# 2. Parse all GDScript files for errors
timeout 30 godot --headless --check-only
```

`gdformat` enforces consistent style (line length, spacing). Run it first so the error check
sees clean code. **Fix all errors before committing.** Do not commit if either command exits
non-zero. `godot --headless --check-only` never exits on its own — always use `timeout 30`.

If errors appear after editing a script:
1. Read the full error including file path and line number
2. Fix the root cause — do not suppress with `@warning_ignore` unless genuinely a false positive
3. Re-run both checks
4. Then commit

---

## Asset Pipeline

### Source folder
All raw Kenney assets live **outside** the project at:
```
/home/dino/projects/assets/
```

When adding assets:
1. `ls` / `find` the source folder to understand what's available
2. Pick the most appropriate file for the purpose
3. Copy **only what is needed** into the relevant subfolder under `res://assets/kenney/`
4. Never reference paths outside `res://` in any script or scene
5. Add the asset to the **Asset Manifest** below
6. Commit with `assets(<scope>): <description>`

### Asset Manifest

> Update this table every time a new asset is copied in.

| File in `res://assets/kenney/` | Source pack | Used by | Purpose |
|-------------------------------|-------------|---------|---------|
| `audio/sfx/bounce_jump.ogg` | Sci-Fi Sounds (`thrusterFire_000`) | `AudioManager` | Player bounces off debris |
| `audio/sfx/damage.ogg` | Impact Sounds (`impactMetal_heavy_000`) | `AudioManager` | Player takes damage |
| `audio/sfx/button_click.ogg` | Interface Sounds (`click_001`) | `AudioManager` | UI button press |
| `audio/sfx/win.ogg` | Interface Sounds (`confirmation_001`) | `AudioManager` | Level complete |
| `audio/sfx/lose.ogg` | Interface Sounds (`error_001`) | `AudioManager` | Game over |
| `audio/sfx/drift_warning.ogg` | Sci-Fi Sounds (`forceField_000`) | `AudioManager` | Drift warning trigger |
| `ui/fonts/Kenney Future.ttf` | UI Pack Space Station | `HUD`, `GameOver`, `MainMenu` | Primary UI font |
| `ui/fonts/Kenney Future Narrow.ttf` | UI Pack Space Station | _(reserved)_ | Compact UI font |
| `ui/png/grey/default/*.png` | UI Pack Space Station | _(available for theming)_ | Bars, buttons, crosshairs |
| `models/space_station/container.glb` | Space Station Kit | `debris_safe.tscn` | Safe debris mesh (cargo container, scaled 3×) |
| `models/space_station/rocks.glb` | Space Station Kit | `debris_hazard.tscn` | Hazard debris mesh (rocks, scaled 3×) |
| `models/space_station/skip.glb` | Space Station Kit | _(reserved)_ | Additional debris variant |
| `models/space_station/Textures/colormap.png` | Space Station Kit | GLB URI resolution | Shared texture atlas for all space station models |
| `models/characters/animal-penguin.glb` | Cube Pets | `player.tscn` | Player character mesh (scaled 1.5×) |

### Recommended Kenney packs for this game
| Pack | Use for |
|------|---------|
| Space Kit | Environment, space station, skybox |
| 3D Platformer | Debris / safe objects |
| Sci-Fi RTS | Hazard objects, boss parts |
| Character Pack (Robot) | Player character |
| UI Pack (Space) | HUD and menu chrome |
| Particle Pack | Jump effects, damage flashes |

---

## Level Data Format

Each level is a `.tres` file using the `LevelData` resource (`core/models/level_data.gd`).
The `.tres` instances live in `resources/levels/`.

```gdscript
# resources/level_data.gd
class_name LevelData
extends Resource

@export var level_id: int = 0
@export var display_name: String = ""
@export var description: String = ""
@export var is_unlocked: bool = false
@export var has_boss: bool = false
@export var debris_theme: String = "generic"       # maps to a spawner config
@export var fall_speed: float = 8.0               # base debris fall speed
@export var corridor_radius: float = 10.0          # how wide the fall tube is
@export var station_approach_speed: float = 1.0    # how fast station descends toward player
@export var unlock_requires: int = -1              # level_id that must be beaten first (-1 = free)
```

---

## Gameplay Constants (tune here first)

These live in their respective scripts as `@export` vars so they're tunable in the editor.
Document the design intent next to each one.

| Constant | Home script | Design intent |
|----------|-------------|---------------|
| `MOVE_SPEED` | `game/player/player.gd` | How fast player slides laterally |
| `JUMP_FORCE` | `game/player/player.gd` | Height gained per bounce |
| `max_fall_speed` | `game/player/player.gd` | Terminal velocity cap so player can always catch the station |
| `DRIFT_LIMIT` | `game/systems/drift_tracker.gd` | Distance from corridor centre before loss |
| `FALL_BEHIND_LIMIT` | `game/systems/drift_tracker.gd` | Distance below station before loss |
| `DEBRIS_FALL_SPEED` | `game/systems/corridor_spawner.gd` | Base downward speed of objects |
| `SPAWN_RATE` | `game/systems/corridor_spawner.gd` | Objects per second |
| `HAZARD_RATIO` | `game/systems/corridor_spawner.gd` | Fraction of debris that are hazards (0–1) |
| `spawn_interval` | `game/systems/pickup_spawner.gd` | Seconds between pickup drops |
| `boost_spawn_ratio` | `game/systems/pickup_spawner.gd` | Fraction of pickups that are boosts vs health (0–1) |

---

## Web Export Checklist

Before shipping an HTML5 build:
- [ ] Export preset configured: Project → Export → Web
- [ ] "Embed PCK" enabled
- [ ] Server sends required headers (itch.io handles this automatically):
  ```
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
  ```
- [ ] Test in Chrome and Firefox
- [ ] Audio works (browsers require a user gesture before first sound)

---

## Running the Game

```bash
godot --main-scene game/gameplay/game.tscn   # run a level directly (skips menu)
godot                                         # open the Godot editor
godot --headless --export-debug "Web" build/  # build HTML5 export
```

---

## Session Workflow for Claude Code

When starting a session:
1. Read this file in full
2. Run `timeout 30 godot --headless --check-only` and note any existing errors
3. Check `git log --oneline -10` to understand recent changes

When finishing a task:
1. Run `~/.local/share/nvim/mason/bin/gdformat .` — format all GDScript files
2. Run `timeout 30 godot --headless --check-only` — fix errors before proceeding
3. Stage and commit with a Conventional Commit message
4. If the task corresponded to a TODO item, mark it `[x]` in this file and include it in the commit
5. Summarise what was done and what the next logical step is

## TODO

### UI / HUD
- [x] Add player health bar
- [x] Add progress bar — starts at 1/3; fills toward station; 0 = "left behind" loss

### Gameplay mechanics
- [x] Cap max fall speed so player can catch the station
- [x] Debris should have varied falling speeds
- [x] Add more debris variety — need wall-type obstacles
- [x] Add huge debris chunk with a doorway the player must navigate through
- [x] Add jetpack boost intro: player starts with a burst, game begins when it runs out

### Pickups
- [x] Health pickup
- [x] Boost pickup for sparse-debris situations

### Tech / refactor
- [x] Refactor end-state strings to use an Enum
- [x] Audit `_process` with `if _emitted: return` — replace with `set_process(false)` where better
- [x] Make level resources auto-loadable from folder

### CI/CD
- [ ] Set up pipeline; use butler to deploy to itch.io
