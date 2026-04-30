# Wall Jumper — GDScript Style Guide

Follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) strictly. Rules below summarise project-specific conventions.

## Naming

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

## File Layout Order (top to bottom)

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

## Types

- **Always** use static typing. Every variable, parameter, and return type must be typed.
- Use `@export` for any value a designer might want to tune.
- Never use `var x = something` — always `var x: Type = something`.

## Functions

- Max **40 lines** per function. If longer, extract a helper.
- One blank line between functions, two blank lines before the first method after properties.
- Use `return` early to avoid deep nesting (guard clauses).

## Comments

- Use `##` doc comments on class definitions and public functions.
- Use `#` inline for *why*, not *what* — the code should explain what.
- No commented-out dead code in commits.

## Misc

- No magic numbers — give everything a named constant.
- Prefer `Vector3.ZERO`, `Color.WHITE` etc. over `Vector3(0,0,0)`.
- Use `push_error()` / `push_warning()` instead of `print()` for diagnostic output.
- `assert()` for invariants that must always hold in debug.
