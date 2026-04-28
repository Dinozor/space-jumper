extends Node2D

# ──────────────────────────────────────────────
#  WallSpawner – generates wall segments and
#  the occasional floor platform as the player
#  climbs. Difficulty ramps over time.
# ──────────────────────────────────────────────

const VIEWPORT_WIDTH  := 480.0
const VIEWPORT_HEIGHT := 800.0

# Wall segment settings
const WALL_WIDTH       := 32.0
const WALL_MIN_HEIGHT  := 80.0
const WALL_MAX_HEIGHT  := 180.0
const GAP_MIN          := 120.0    # minimum gap between left/right walls
const GAP_MAX          := 260.0    # maximum gap at start
const SEGMENT_SPACING  := 120.0    # vertical distance between new segments

# Platform (floor bounce helper) settings
const PLATFORM_CHANCE  := 0.20     # 20% chance a gap gets a small platform
const PLATFORM_W       := 90.0
const PLATFORM_H       := 16.0

# Difficulty scaling
const DIFF_RAMP_SCORE  := 500.0    # every 500 pts difficulty ticks up
var _difficulty        := 0.0

# Preloaded scenes
@export var wall_scene     : PackedScene
@export var platform_scene : PackedScene

var _camera : Camera2D
var _spawn_y := 0.0      # next y to spawn at
var _segments : Array[Node] = []

func _ready() -> void:
	var cams := get_tree().get_nodes_in_group("main_camera")
	if not cams.is_empty():
		_camera = cams[0]

	# Pre-fill the visible area
	_spawn_y = 100.0
	for i in 10:
		_spawn_row()
		_spawn_y -= SEGMENT_SPACING

func _process(_delta: float) -> void:
	if not _camera:
		return

	# Spawn new rows ahead of camera
	var cam_top := _camera.global_position.y - VIEWPORT_HEIGHT * 0.5
	while _spawn_y > cam_top - SEGMENT_SPACING * 2:
		_spawn_y -= SEGMENT_SPACING
		_spawn_row()

	# Cull old rows far below camera
	var cam_bottom := _camera.global_position.y + VIEWPORT_HEIGHT
	for seg in _segments.duplicate():
		if is_instance_valid(seg) and seg.global_position.y > cam_bottom:
			seg.queue_free()
			_segments.erase(seg)

func _spawn_row() -> void:
	_difficulty = clamp(abs(_spawn_y) / DIFF_RAMP_SCORE, 0.0, 1.0)

	# Calculate gap (shrinks as difficulty rises)
	var gap_w: float = lerp(GAP_MAX, GAP_MIN + 20.0, _difficulty)
	var gap_x := randf_range(WALL_WIDTH, VIEWPORT_WIDTH - WALL_WIDTH - gap_w)

	# Left wall segment
	_spawn_wall(0.0, _spawn_y, gap_x)

	# Right wall segment
	var right_x := gap_x + gap_w
	_spawn_wall(right_x, _spawn_y, VIEWPORT_WIDTH - right_x)

	# Optional mid-gap platform
	if randf() < PLATFORM_CHANCE + _difficulty * 0.15:
		var px := gap_x + gap_w * 0.5 - PLATFORM_W * 0.5
		_spawn_platform(px, _spawn_y)

func _spawn_wall(x: float, y: float, width: float) -> void:
	if not wall_scene:
		_spawn_wall_primitive(x, y, width)
		return
	var inst := wall_scene.instantiate()
	add_child(inst)
	inst.global_position = Vector2(x, y)
	if inst.has_method("set_size"):
		inst.set_size(Vector2(width, WALL_MIN_HEIGHT + randf() * (WALL_MAX_HEIGHT - WALL_MIN_HEIGHT)))
	_segments.append(inst)

func _spawn_platform(x: float, y: float) -> void:
	if not platform_scene:
		_spawn_platform_primitive(x, y)
		return
	var inst := platform_scene.instantiate()
	add_child(inst)
	inst.global_position = Vector2(x, y)
	_segments.append(inst)

# ── Primitive fallbacks (no asset needed) ────────
func _spawn_wall_primitive(x: float, y: float, width: float) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	var h := WALL_MIN_HEIGHT + randf() * (WALL_MAX_HEIGHT - WALL_MIN_HEIGHT)
	rect.size = Vector2(width, h)
	shape.shape = rect
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.size    = Vector2(width, h)
	visual.position = Vector2(-width * 0.5, -h * 0.5)
	visual.color   = _wall_color()
	body.add_child(visual)

	add_child(body)
	body.global_position = Vector2(x + width * 0.5, y)
	_segments.append(body)

func _spawn_platform_primitive(x: float, y: float) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size = Vector2(PLATFORM_W, PLATFORM_H)
	shape.shape = rect
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.size     = Vector2(PLATFORM_W, PLATFORM_H)
	visual.position = Vector2(-PLATFORM_W * 0.5, -PLATFORM_H * 0.5)
	visual.color    = Color(0.4, 0.85, 0.5)
	body.add_child(visual)

	add_child(body)
	body.global_position = Vector2(x + PLATFORM_W * 0.5, y)
	_segments.append(body)

func _wall_color() -> Color:
	# Subtle color variety tied to height
	var hue := fmod(abs(_spawn_y) / 2000.0, 1.0)
	return Color.from_hsv(hue, 0.35, 0.72)
