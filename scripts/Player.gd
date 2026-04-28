extends CharacterBody2D

# ──────────────────────────────────────────────
#  Wall Jumper – Player Controller
#  Kenney 3D assets assumed (set up in Main.tscn)
# ──────────────────────────────────────────────

# Movement constants
const GRAVITY          := -10 #980.0
const WALL_JUMP_FORCE  := Vector2(420.0, -700.0)  # x away from wall, y upward
const AUTO_JUMP_FORCE  := -560.0                   # auto-bounce off floor (Doodle Jump feel)
const WALL_SLIDE_SPEED := 80.0                     # max downward speed while sliding wall
const MOVE_SPEED       := 220.0                    # horizontal air movement
const WALL_JUMP_GRACE  := 0.12                     # seconds of coyote time on wall

# State
var _wall_jump_timer  := 0.0
var _last_wall_normal := Vector2.ZERO
var _touching_left    := false
var _touching_right   := false
var _score            := 0
var _highest_y        := 0.0
var _alive            := true

# Visual feedback
var _sprite: Node2D   # Will be a MeshInstance3D or AnimatedSprite3D from Kenney pack
var _trail_particles: GPUParticles2D

signal died
signal score_changed(new_score: int)

func _ready() -> void:
	_highest_y = global_position.y
	_sprite = $Visual          # Assign in scene
	_trail_particles = $Trail  # Optional particle trail

func _physics_process(delta: float) -> void:
	if not _alive:
		return

	_wall_jump_timer = max(0.0, _wall_jump_timer - delta)

	_detect_walls()
	_apply_gravity(delta)
	_handle_input()
	_clamp_wall_slide()
	_auto_floor_bounce()

	move_and_slide()

	_update_score()
	_check_fall_death()

# ── Wall detection ──────────────────────────────
func _detect_walls() -> void:
	_touching_left  = false
	_touching_right = false

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var n   := col.get_normal()
		if abs(n.x) > 0.7:          # Mostly horizontal normal → wall
			if n.x > 0:
				_touching_left  = true
				_last_wall_normal = n
			else:
				_touching_right = true
				_last_wall_normal = n
			_wall_jump_timer = WALL_JUMP_GRACE

# ── Gravity ─────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if _on_wall() and velocity.y > 0:
		# Slow slide when pressing into wall
		velocity.y += GRAVITY * delta * 0.3
	else:
		velocity.y += GRAVITY * delta

# ── Player input ────────────────────────────────
func _handle_input() -> void:
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * MOVE_SPEED

	if Input.is_action_just_pressed("jump") and _can_wall_jump():
		_do_wall_jump()

# ── Wall jump logic ─────────────────────────────
func _on_wall() -> bool:
	return _touching_left or _touching_right

func _can_wall_jump() -> bool:
	return _wall_jump_timer > 0.0

func _do_wall_jump() -> void:
	var force := WALL_JUMP_FORCE
	# Push away from the wall the player is touching
	if _touching_left:
		force.x =  abs(force.x)    # push right
	else:
		force.x = -abs(force.x)    # push left

	velocity = force
	_wall_jump_timer = 0.0
	_play_jump_effect()

# ── Auto-bounce off floor platforms ─────────────
# Keeps the Doodle Jump feel – landing on a platform auto-launches you
func _auto_floor_bounce() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var n   := col.get_normal()
		if n.y < -0.7 and velocity.y > 0:        # Hit top of something
			velocity.y = AUTO_JUMP_FORCE
			_play_jump_effect()
			break

# ── Clamp slide speed ────────────────────────────
func _clamp_wall_slide() -> void:
	if _on_wall():
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

# ── Score from height ────────────────────────────
func _update_score() -> void:
	if global_position.y < _highest_y:
		_highest_y = global_position.y
		_score = int((_highest_y * -1) / 10.0)
		emit_signal("score_changed", _score)

# ── Fell off screen ──────────────────────────────
func _check_fall_death() -> void:
	# Camera reference via group – set up in Main.tscn
	var cams := get_tree().get_nodes_in_group("main_camera")
	if cams.is_empty():
		return
	var cam: Camera2D = cams[0]
	var bottom := cam.global_position.y + 500.0
	if global_position.y > bottom:
		_die()

func _die() -> void:
	if not _alive:
		return
	_alive = false
	emit_signal("died")

# ── Visual feedback ──────────────────────────────
func _play_jump_effect() -> void:
	if _trail_particles:
		_trail_particles.restart()
	# Squash & stretch
	if _sprite:
		var tween := create_tween()
		tween.tween_property(_sprite, "scale",
			Vector3(1.4, 0.6, 1.0), 0.05)
		tween.tween_property(_sprite, "scale",
			Vector3(0.8, 1.3, 1.0), 0.07)
		tween.tween_property(_sprite, "scale",
			Vector3(1.0, 1.0, 1.0), 0.10)
