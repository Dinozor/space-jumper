# Story Reframe + Level Select Orbital Map — Design Spec

**Goal:** Replace the generic "falling debris" narrative with an exploded-station story, rename/add levels to match station sections, and replace the level select list with an orbital map UI.

**Architecture:** Pure content and UI change — no new gameplay mechanics. Existing LevelData schema, unlock chain, and win conditions are unchanged. Level select scene is rebuilt around a custom Control layout; level `.tres` files are renamed and extended to 6 total.

**No gameplay mechanics change.** The cable-grab win cinematic already serves as "fixing" the piece narratively.

---

## Story

The space station exploded. The player survived, adrift in the debris field with wreckage orbiting the planet below. Each level is one station section floating in orbit. Reaching the cable at the top of a section = patching it. The final level is the enemy ship responsible.

This is expressed through:
- Level display names and descriptions in `.tres` files
- Main menu subtitle text (one-line change)
- Level select visual layout (orbital map)

---

## Levels

Six levels total. Existing three levels are renamed/reconfigured; three new ones added.

| level_id | File | display_name | unlock_requires | has_cable_ending | station_escape_speed | drag |
|----------|------|--------------|-----------------|------------------|----------------------|------|
| 1 | `cargo_bay.tres` | Cargo Bay | -1 (free) | true | 7.0 | 0.35 |
| 2 | `reactor_core.tres` | Reactor Core | 1 | true | 9.0 | 0.4 |
| 3 | `bridge.tres` | Bridge | 2 | true | 11.0 | 0.45 |
| 4 | `command_deck.tres` | Command Deck | 3 | true | 13.0 | 0.5 |
| 5 | `hull_section.tres` | Hull Section | 4 | true | 15.0 | 0.55 |
| 6 | `enemy_ship.tres` | Enemy Ship | 5 | false | 12.0 | 0.4 |

- `enemy_ship.tres` sets `has_boss = true` and `has_cable_ending = false` (boss handles the win).
- Old files `test_level.tres`, `level_training.tres`, `level_02.tres` are deleted.
- All other LevelData fields (corridor_radius, spawn_table, sections) carry sensible defaults.

---

## Level Select — Orbital Map

### Layout

The level select is a single `Control` node. All layout is built in GDScript (no sub-scenes per node) following the existing `_build_ui()` pattern.

**Layers (back to front):**

1. **Background** — `ColorRect` filling the screen, color `#06080f`
2. **Stars** — small `ColorRect` dots scattered at fixed positions
3. **Planet** — large `ColorRect` with a circular `StyleBoxFlat` (corner radius = half width), pushed ~60% off the bottom edge so only the top arc is visible. Color: deep blue `#1e3370` with a glow `StyleBoxFlat` shadow.
4. **Orbit arc** — `Line2D` or `ColorRect` drawn as a flattened ellipse outline (dashed appearance via repeated short segments), sitting above the planet curve.
5. **Level nodes** — one `Button` per level, positioned along the arc. Beaten = blue border + glow; active/next = bright pulse; locked = dimmed, `disabled = true`.
6. **Enemy ship node** — `Button` in upper-right corner, circular style, red border, locked until level 5 beaten.
7. **Back button** — bottom center.

### Node positions

Nodes are spaced evenly along a parametric ellipse arc. Given N = 5 regular levels + 1 boss:

```
arc_center  = Vector2(screen_width * 0.5, screen_height + 120.0)  # 120 px below screen bottom
arc_rx      = screen_width * 0.46   # horizontal radius
arc_ry      = screen_height * 0.28  # vertical radius (flat ellipse)
angle_start = PI * 1.18             # left side of arc
angle_end   = PI * 1.82             # right side of arc
```

Each regular level node `i` (0..4) is placed at:
```
t = i / 4.0
angle = lerp(angle_start, angle_end, t)
pos = arc_center + Vector2(cos(angle) * arc_rx, sin(angle) * arc_ry)
```

Enemy ship node is fixed at `Vector2(screen_width - 60, 40)`.

### Visual states per node

| State | Border color | Background | Glow | Clickable |
|-------|-------------|-----------|------|-----------|
| Beaten | `#4a9eff` | `#132a66` | soft blue | yes |
| Active (next to play) | `#aaccff` | `#1a3355` | bright pulsing blue | yes |
| Locked | `#444444` | `#1a1a1a` | none | no |
| Boss locked | `#ff3333` | `#1a0505` | soft red | no |
| Boss unlocked | `#ff3333` | `#1a0505` | pulsing red | yes |

Active node animates via `_process`: `modulate` alpha oscillates between 0.85 and 1.0.

### Interaction

Clicking a level node sets `GameState.current_level = level.level_id` and calls `get_tree().change_scene_to_file("res://game/gameplay/game.tscn")`. Same as current behavior. Scores button per level remains (small button beside each node label, same as current level select).

---

## Files Created / Modified

| Action | Path |
|--------|------|
| Delete | `resources/levels/test_level.tres` |
| Delete | `resources/levels/level_training.tres` |
| Delete | `resources/levels/level_02.tres` |
| Create | `resources/levels/cargo_bay.tres` |
| Create | `resources/levels/reactor_core.tres` |
| Create | `resources/levels/bridge.tres` |
| Create | `resources/levels/command_deck.tres` |
| Create | `resources/levels/hull_section.tres` |
| Create | `resources/levels/enemy_ship.tres` |
| Modify | `game/menu/level_select.gd` — full rewrite of `_build_ui()` |
| Modify | `game/menu/level_select.tscn` — root stays Control; remove ButtonContainer |
| Modify | `game/menu/main_menu.gd` — update subtitle string |
