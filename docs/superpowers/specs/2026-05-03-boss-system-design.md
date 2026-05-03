# Boss System — Design Spec

**Goal:** Add a boss encounter to the final level (Enemy Ship). The boss fires projectiles, some deflectable by player contact. Player can also shoot the boss directly with the shooting ability. Boss dies when HP reaches 0; that triggers the win.

**Architecture:** New `BossShip` node spawns at the top of the corridor when `level_data.has_boss` is true. It owns its own projectile spawning loop. Win condition for boss levels replaces `station_reached` with `boss_defeated` signal. No changes to player physics or existing ability code.

**Depends on:** Story Reframe spec (enemy_ship.tres must exist with `has_boss = true`).

---

## LevelData change

Add one field to `core/models/level_data.gd`:

```gdscript
@export var boss_hp: int = 5
```

`enemy_ship.tres` sets `boss_hp = 5`. All other levels leave it at default (unused when `has_boss = false`).

---

## BossShip (`game/objects/boss_ship.gd` / `.tscn`)

### Scene structure

```
BossShip (Node3D)
  Mesh (MeshInstance3D)      ← simple box mesh, distinct color; swap for Kenney asset later
  HitArea (Area3D)           ← detects incoming player projectiles
    CollisionShape3D
  SpawnPoint (Marker3D)      ← projectiles spawn from here (bottom of ship)
```

### Behaviour

```gdscript
signal defeated
signal hp_changed(current: int, max_hp: int)

@export var hp: int = 5
@export var fire_interval: float = 2.0      # seconds between projectile bursts
@export var deflectable_ratio: float = 0.6  # fraction of projectiles that are deflectable
```

- On `_ready`: creates a `Timer` node (`_fire_timer`), sets `wait_time = fire_interval`, connects `timeout` to `_fire`. Does NOT start it — `start_firing()` does that.
- `start_firing()`: calls `_fire_timer.start()`. Called by `Game` after intro depletes.
- `_fire()` spawns 1–3 `BossProjectile` nodes at `SpawnPoint.global_position`, each aimed slightly toward `_player.global_position` (XZ spread ±2 units). Each projectile is independently assigned `deflectable = randf() < deflectable_ratio`.
- `_player` reference is set by `Game._spawn_boss()` via `_boss.player = _player` (public var).
- `HitArea.body_entered`: when a player projectile (tagged `"player_bullet"`) or a deflected boss projectile enters, calls `take_hit()`.
- `take_hit()`: decrements `hp`, emits `hp_changed`. If `hp <= 0`, emits `defeated` and calls `queue_free()`.

### Positioning

`Game._begin_boss()` places BossShip at `Vector3(0, _level_manager.station_y - 5.0, 0)`. The ship stays fixed in world space (no `station_escape_speed` applied to it — it hovers at the top).

---

## BossProjectile (`game/objects/boss_projectile.gd` / `.tscn`)

### Scene structure

```
BossProjectile (CharacterBody3D)
  Mesh (MeshInstance3D)      ← sphere: blue tint if deflectable, red if not
  CollisionShape3D
```

### Behaviour

```gdscript
@export var deflectable: bool = false
@export var speed: float = 12.0
var _direction: Vector3 = Vector3.DOWN
var _deflected: bool = false
```

- Moves in `_direction * speed` each physics frame via `move_and_slide()`.
- `_handle_slide_collisions()`: checks each collision's collider.
  - If collider is `Player` and `deflectable` and not `_deflected`:
    - Flip `_direction` to point toward `BossShip` world position.
    - Set `_deflected = true` (can only deflect once).
    - Add `"player_bullet"` to groups so `BossShip.HitArea` recognises it.
  - If collider is `Player` and (not `deflectable` or `_deflected`):
    - Call `player.take_damage(1)`.
    - Call `queue_free()`.
  - If collider is `BossShip` (checked via group `"boss"`): `queue_free()` (BossShip's Area3D handles the hit detection).
- Self-destructs after 6 seconds (`get_tree().create_timer(6.0).timeout.connect(queue_free)`).

---

## Game integration (`game/gameplay/game.gd`)

### New fields

```gdscript
var _boss: BossShip = null
```

### `_apply_level_data()` addition

```gdscript
if level_data.has_boss:
    _spawn_boss()
```

### `_spawn_boss()`

```gdscript
func _spawn_boss() -> void:
    var scene := preload("res://game/objects/boss_ship.tscn")
    _boss = scene.instantiate() as BossShip
    _boss.hp = level_data.boss_hp
    _boss.player = _player
    _boss.position = Vector3(0.0, _level_manager.station_y - 5.0, 0.0)
    _boss.defeated.connect(_on_boss_defeated)
    _boss.hp_changed.connect(_hud.update_boss_hp)
    add_child(_boss)
    _hud.show_boss_bar(true)
    _hud.update_boss_hp(level_data.boss_hp, level_data.boss_hp)
```

### `_on_boss_defeated()`

```gdscript
func _on_boss_defeated() -> void:
    if _game_ended:
        return
    _game_ended = true
    _record_attempt(EndState.keys()[EndState.WON])
    _award_currency()
    AudioManager.play_win()
    level_won.emit()
    _win_screen.show_result(
        level_data.level_reward if level_data != null else 0, GameState.currency
    )
```

### `_on_station_reached()` guard

Add early return when boss level (station cable doesn't fire the win):

```gdscript
func _on_station_reached() -> void:
    if level_data != null and level_data.has_boss:
        return
    # ... existing win logic
```

### Boss intro

Boss only starts firing after the intro jetpack depletes. In `_on_jetpack_depleted()`:

```gdscript
if _boss != null:
    _boss.start_firing()
```

`BossShip.start_firing()` starts the fire timer. Timer is NOT started in `_ready()`.

---

## HUD additions

Two new methods in `game/ui/hud.gd`:

```gdscript
func show_boss_bar(show: bool) -> void:
    _boss_bar.visible = show

func update_boss_hp(current: int, max_hp: int) -> void:
    _boss_bar.max_value = float(max_hp)
    _boss_bar.value = float(current)
```

`_boss_bar` is a new `ProgressBar` node in `hud.tscn`, hidden by default, styled red. Positioned at the top of the screen (above the station progress bar).

---

## Shooting ability integration

The existing shooting ability fires `PlayerBullet` nodes that already check for `"shootable"` tagged objects. No change needed — add `BossShip` to the `"shootable"` group in its `_ready()`:

```gdscript
func _ready() -> void:
    add_to_group("boss")
    add_to_group("shootable")
```

The existing bullet collision code calls `on_player_contact` or checks groups — verify the bullet hits `HitArea` correctly. If not, add `"player_bullet"` group to the bullet in the shooting ability scene and have `BossShip.HitArea` detect it via `body_entered`.

---

## Files Created / Modified

| Action | Path |
|--------|------|
| Create | `game/objects/boss_ship.tscn` |
| Create | `game/objects/boss_ship.gd` |
| Create | `game/objects/boss_projectile.tscn` |
| Create | `game/objects/boss_projectile.gd` |
| Modify | `core/models/level_data.gd` — add `boss_hp` |
| Modify | `resources/levels/enemy_ship.tres` — set `boss_hp = 5` |
| Modify | `game/gameplay/game.gd` — spawn boss, `_on_boss_defeated`, guard `_on_station_reached` |
| Modify | `game/ui/hud.gd` — `show_boss_bar`, `update_boss_hp` |
| Modify | `game/ui/hud.tscn` — add `BossBar` ProgressBar node |
