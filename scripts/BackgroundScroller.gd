extends Node2D

# ──────────────────────────────────────────────
#  BackgroundScroller
#  Generates a simple parallax star/grid effect
#  using plain primitives so it works before
#  Kenney assets are imported.
#
#  Replace the ColorRect with a Kenney background
#  sprite once you have the assets:
#    1. Import kenney_backgroundElements or similar
#    2. Add a TextureRect child, assign texture
#    3. Delete the ColorRect children
# ──────────────────────────────────────────────

const TILE_H := 800.0

var _camera : Camera2D
var _tiles  : Array[ColorRect] = []

func _ready() -> void:
	# Sky gradient tile – duplicated to fill screen infinitely
	for i in 3:
		var cr := ColorRect.new()
		cr.size    = Vector2(480, TILE_H)
		cr.color   = Color(0.08, 0.10, 0.22)   # deep navy
		cr.position = Vector2(0, -TILE_H * i)
		add_child(cr)
		_tiles.append(cr)

	var cams := get_tree().get_nodes_in_group("main_camera")
	if not cams.is_empty():
		_camera = cams[0]

func _process(_delta: float) -> void:
	if not _camera:
		return
	var cam_y := _camera.global_position.y
	# Keep tiles tiled around camera
	for tile in _tiles:
		var rel := tile.position.y - cam_y
		if rel > TILE_H:
			tile.position.y -= TILE_H * _tiles.size()
		elif rel < -TILE_H * 2:
			tile.position.y += TILE_H * _tiles.size()
