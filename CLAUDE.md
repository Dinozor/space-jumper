# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Project

- **Engine:** Godot 4.6 (open `project.godot` in Godot 4.3+)
- **Run:** Press **F5** in the Godot editor (or `Project → Run`)
- **No build step:** GDScript is interpreted at runtime; Godot hot-reloads changes during development
- **Web export:** `Project → Export → Web (HTML5)`, enable "Embed PCK". Requires COOP headers when self-hosting (itch.io handles this automatically)

## Architecture

The game is a Doodle Jump–style vertical climber. `scenes/Main.tscn` is the root scene; `scripts/Main.gd` wires all the signals together.

```
Main.tscn / Main.gd (orchestrator)
├── Player (CharacterBody2D) → Player.gd
│   ├── Sprite2D (placeholder rect)
│   ├── GPUParticles2D (trail on jump)
│   └── Camera2D → FollowCamera.gd
├── WallSpawner (Node2D) → WallSpawner.gd
│   ├── spawns WallSegment.tscn instances (left+right walls per row)
│   └── spawns Platform.tscn instances (bounce platforms in the gap)
├── BackgroundScroller (Node2D) → BackgroundScroller.gd
└── GameUI (CanvasLayer) → GameUI.gd
    ├── ScoreLabel, BestLabel
    └── GameOverPanel
```

### Key scripts

| Script | Responsibility |
|---|---|
| `Player.gd` | Physics, wall-jump detection, coyote time, scoring |
| `WallSpawner.gd` | Procedural row generation, difficulty scaling, culling off-screen rows |
| `FollowCamera.gd` | Upward-only camera follow with lead offset |
| `GameUI.gd` | Score display; best score persisted via system clipboard |
| `BackgroundScroller.gd` | Parallax navy-sky tiles |

### Core gameplay loop

1. **Gravity** is applied continuously; the player wall-slides at terminal velocity (`WALL_SLIDE_SPEED = 80`).
2. **Wall jump** launches the player away from the wall (`WALL_JUMP_FORCE = Vector2(420, -700)`) with a 0.12 s coyote-time grace period.
3. **WallSpawner** generates new rows ahead of the camera and culls rows that scroll off the bottom. Gap width shrinks linearly from 260 px → 140 px as score increases (difficulty = `min(score/500, 1.0)`).
4. **Score** = `floor(abs(height_climbed) / 10)`. Game over when the player falls >500 px below the camera center.

### Tuning constants

Physics constants are at the top of `scripts/Player.gd`; level-generation constants are at the top of `scripts/WallSpawner.gd`. Adjust those when tweaking feel or difficulty.

## Project Configuration

`project.godot` defines:
- Viewport: 480×800, stretched via `canvas_items`, mobile renderer
- Input map: `move_left` (A/←), `move_right` (D/→), `jump` (Space/↑)
- Main scene: `res://scenes/Main.tscn`

## Asset Integration

The game ships with colored-rectangle placeholders. To swap in Kenney assets, replace the `Sprite2D` texture on `Player` and the `ColorRect` in `WallSegment.tscn`/`Platform.tscn` with the appropriate PNG sprites (see README.md for detailed steps).
