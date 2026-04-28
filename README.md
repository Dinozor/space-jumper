# Wall Jumper 🧱⬆️
*A sideways Doodle Jump where wall-jumping is everything*

---

## Quick Start

1. **Open** the project folder in **Godot 4.3+** (File → Open Project → select `project.godot`).
2. Hit **F5** (Run Project). The game runs immediately with placeholder graphics.
3. Follow the Kenney asset steps below to get the 3D look.

---

## Controls

| Action | Key |
|--------|-----|
| Move left / right | A / D or ← / → |
| Wall jump | Space or ↑ |

**How to play:** You fall between two walls. Press into a wall and hit **Jump** to launch yourself across to the other wall. Chain wall jumps to climb as high as possible. Small platforms occasionally appear in the gap — land on one for a free bounce upward.

---

## Project Structure

```
wall_jumper/
├── project.godot          ← Godot 4 project config
├── scenes/
│   ├── Main.tscn          ← Root scene (load this)
│   ├── WallSegment.tscn   ← Wall block (replace visual with Kenney)
│   └── Platform.tscn      ← Gap platform
├── scripts/
│   ├── Main.gd            ← Scene wiring
│   ├── Player.gd          ← Wall-jump physics
│   ├── FollowCamera.gd    ← Upward-only follow cam
│   ├── WallSpawner.gd     ← Procedural wall generation
│   ├── BackgroundScroller.gd ← Parallax BG
│   └── GameUI.gd          ← Score, game over
└── assets/                ← Drop Kenney assets here
    └── kenney/
```

---

## Adding Kenney 3D Assets

The game ships with colored rectangles. Here's how to swap in Kenney assets for the 3D look:

### Recommended Kenney Packs
All free at **kenney.nl/assets**:

| Pack | Use for |
|------|---------|
| **3D Platformer** | Wall blocks (`.glb`) |
| **Minigolf Pack** | Clean modular walls |
| **Isometric Blocks** | Stylised wall look |
| **Particle Pack** | Jump/trail effects |
| **UI Pack (Space)** | Score HUD chrome |

### Option A – Sprite2D from pre-rendered PNG (easiest)
1. Download a Kenney pack with PNG spritesheets (e.g. *Pixel Platformer*).
2. Import the PNG into `res://assets/kenney/`.
3. In **WallSegment.tscn**, select the `Visual` node → change type to `Sprite2D`.
4. Assign the texture and set `RegionEnabled = true` to crop the right tile.

### Option B – 3D mesh inside a SubViewport (best 3D look)
1. Download **Kenney 3D Platformer** (`.glb` models).
2. Import `.glb` into `res://assets/kenney/`. Godot auto-imports as `PackedScene`.
3. In **WallSegment.tscn**:
   - Add a `SubViewportContainer` child to the scene root.
   - Inside it add a `SubViewport`, inside that a `Node3D`.
   - Instance the Kenney `.glb` inside the `Node3D`.
   - Add a `Camera3D` and `DirectionalLight3D` inside the SubViewport.
   - Set `SubViewportContainer` size to match your wall dimensions.
4. The 3D model now renders as a 2D texture on the wall segment.

### Player Visual
In **Main.tscn**, the `Player/Visual` node is a plain `Node2D`. Replace it:
- For **2D**: add `Sprite2D`, assign a Kenney character PNG.
- For **3D in SubViewport**: same SubViewport trick as walls.

Kenney's **"3D Characters"** pack has a great little robot that fits perfectly.

---

## Tuning the Feel

Open `scripts/Player.gd` and tweak the constants at the top:

```gdscript
const WALL_JUMP_FORCE  := Vector2(420.0, -700.0)  # x = push-off, y = launch height
const AUTO_JUMP_FORCE  := -560.0                   # floor platform bounce strength
const WALL_SLIDE_SPEED := 80.0                     # how fast you slide down walls
const MOVE_SPEED       := 220.0                    # air control speed
```

Open `scripts/WallSpawner.gd` to tune the level generation:

```gdscript
const GAP_MIN          := 120.0    # narrowest gap between walls (hard)
const GAP_MAX          := 260.0    # widest gap at start (easy)
const SEGMENT_SPACING  := 120.0    # vertical distance between wall rows
const PLATFORM_CHANCE  := 0.20     # frequency of bonus platforms
const DIFF_RAMP_SCORE  := 500.0    # score points per difficulty level
```

---

## Exporting for Web (HTML5)

1. In Godot: **Project → Export**.
2. Click **Add…** → **Web**.
3. Set **Export Path** to e.g. `build/index.html`.
4. Tick **Embed PCK** for a single-file export.
5. Click **Export Project**.
6. Upload the output folder to **itch.io**, **GitHub Pages**, or **Netlify**.

> **COOP headers required!** For the Godot 4 web export threading to work, your server must send:
> ```
> Cross-Origin-Opener-Policy: same-origin
> Cross-Origin-Embedder-Policy: require-corp
> ```
> itch.io handles this automatically. For GitHub Pages, add a `_headers` file.

---

## Ideas for Expansion

- **Enemy blobs** that stick to walls and fall when hit
- **Moving walls** that slide horizontally (great tension builder)
- **Power-ups** in the gap: jetpack boost, slowmo, sticky shoes
- **Boss walls** that close in periodically (avoid getting squished!)
- **Combo multiplier** for wall-jumping without touching the floor
- **Local leaderboard** (Godot's `FileAccess` for persistent best scores)
