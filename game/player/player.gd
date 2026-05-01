class_name Player
extends CharacterBody3D

## Player controller: handles XZ movement, bounce physics, drift, and abilities.

signal jumped
signal damaged(amount: int)
signal healed
signal died
signal jetpack_depleted

const MOVE_SPEED: float = 8.0
const BOUNCE_FORCE: float = 12.0
const MIN_VERTICAL_BOUNCE: float = 0.7
const LATERAL_BOUNCE_FACTOR: float = 1.8
const LATERAL_BOUNCE_DECAY: float = 3.0
## Multiplier applied to bounce decay when input opposes bounce direction.
## Lets the player actively brake or redirect after a wall hit.
const LATERAL_BRAKE_FACTOR: float = 4.0

@export var rotation_speed: float = 10.0
@export var max_tilt_angle: float = 0.35
@export var jetpack_duration: float = 3.0
@export var jetpack_force: float = 15.0

var stats: PlayerStats = PlayerStats.new()
var station_escape_speed: float = 10.0
var drag: float = 0.5
var input_locked: bool = false
var invincible: bool = false

var _velocity: Vector3 = Vector3.ZERO
var _lateral_bounce: Vector3 = Vector3.ZERO
var _jetpack_active: bool = false
var _jetpack_timer: float = 0.0
var _was_on_floor: bool = false
var _abilities: Array[PlayerAbility] = []
var _move_speed_override: float = MOVE_SPEED
var _bounce_force_override: float = BOUNCE_FORCE
var _aerodynamics: float = 1.0

@onready var _mesh: Node3D = $Mesh


func _ready() -> void:
	_apply_character_stats()
	_build_abilities()


func _apply_character_stats() -> void:
	var char_data: CharacterData = GameState.get_current_character()
	if char_data == null:
		return
	var id: String = char_data.character_id
	var f: float = char_data.upgrade_factor
	var speed_bonus: float = pow(f, GameState.get_upgrade_tier(id, "move_speed"))
	var jump_bonus: float = pow(f, GameState.get_upgrade_tier(id, "jump_force"))
	var aero_bonus: float = pow(f, GameState.get_upgrade_tier(id, "aerodynamics"))
	_move_speed_override = char_data.move_speed * speed_bonus
	_bounce_force_override = char_data.jump_force * jump_bonus
	_aerodynamics = char_data.aerodynamics * aero_bonus


func _build_abilities() -> void:
	for id: String in GameState.purchased_abilities:
		var data: AbilityData = GameState.get_ability_data(id)
		if data == null or data.scene == null:
			continue
		var ability: PlayerAbility = data.scene.instantiate() as PlayerAbility
		if ability == null:
			continue
		add_child(ability)
		_abilities.append(ability)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement(delta)
	_apply_jump_input()
	_apply_velocity(delta)
	_tick_abilities(delta)
	_check_landed()
	_rotate_mesh(delta)


func _tick_abilities(delta: float) -> void:
	for ab: PlayerAbility in _abilities:
		ab.tick(self, delta)


func _check_landed() -> void:
	if is_on_floor() and not _was_on_floor:
		for ab: PlayerAbility in _abilities:
			ab.on_landed()
	_was_on_floor = is_on_floor()


func _apply_jump_input() -> void:
	if input_locked or not Input.is_action_just_pressed("jump"):
		return
	if is_on_floor():
		return
	for ab: PlayerAbility in _abilities:
		if ab.consume_extra_jump():
			apply_boost(BOUNCE_FORCE)
			return


func start_jetpack() -> void:
	_jetpack_active = true
	_jetpack_timer = jetpack_duration


func get_jetpack_fuel_ratio() -> float:
	if not _jetpack_active:
		return 0.0
	return _jetpack_timer / jetpack_duration


func refill_jetpack(amount: float) -> void:
	_jetpack_timer = minf(_jetpack_timer + amount, jetpack_duration)
	if amount > 0.0 and not _jetpack_active:
		_jetpack_active = true


func apply_boost(force: float) -> void:
	_velocity.y = force
	AudioManager.play_jump()
	jumped.emit()


func bounce(normal: Vector3) -> void:
	_velocity.y = maxf(normal.y, MIN_VERTICAL_BOUNCE) * _bounce_force_override
	var lateral: Vector3 = (
		Vector3(normal.x, 0.0, normal.z) * _bounce_force_override * LATERAL_BOUNCE_FACTOR
	)
	for ab: PlayerAbility in _abilities:
		lateral = ab.modify_lateral_bounce(lateral)
	_lateral_bounce = lateral
	AudioManager.play_jump()
	jumped.emit()


func heal(amount: int) -> void:
	stats.health = mini(stats.health + amount, PlayerStats.MAX_HEALTH)
	healed.emit()


func take_damage(amount: int) -> void:
	if invincible:
		return
	stats.health -= amount
	AudioManager.play_damage()
	damaged.emit(amount)
	if stats.health <= 0:
		died.emit()


func _apply_gravity(delta: float) -> void:
	if _jetpack_active:
		_velocity.y = jetpack_force
		_jetpack_timer -= delta
		if _jetpack_timer <= 0.0:
			_jetpack_active = false
			jetpack_depleted.emit()
		return
	if _velocity.y > 0.0:
		_velocity.y *= 1.0 - drag * _aerodynamics * delta
	_velocity.y -= station_escape_speed * delta
	_velocity.y = maxf(_velocity.y, -station_escape_speed)


func _apply_movement(delta: float) -> void:
	if input_locked:
		_velocity.x = 0.0
		_velocity.z = 0.0
		return
	var input: Vector3 = Vector3(
		Input.get_axis("move_left", "move_right"), 0.0, Input.get_axis("move_forward", "move_back")
	)
	var brake_x: float = LATERAL_BRAKE_FACTOR if input.x * _lateral_bounce.x < 0.0 else 1.0
	var brake_z: float = LATERAL_BRAKE_FACTOR if input.z * _lateral_bounce.z < 0.0 else 1.0
	_lateral_bounce.x = move_toward(_lateral_bounce.x, 0.0, LATERAL_BOUNCE_DECAY * brake_x * delta)
	_lateral_bounce.z = move_toward(_lateral_bounce.z, 0.0, LATERAL_BOUNCE_DECAY * brake_z * delta)
	_velocity.x = input.x * _move_speed_override + _lateral_bounce.x
	_velocity.z = input.z * _move_speed_override + _lateral_bounce.z


func _apply_velocity(_delta: float) -> void:
	velocity = _velocity
	move_and_slide()
	_velocity = velocity
	_handle_slide_collisions()


func _handle_slide_collisions() -> void:
	var contacted: Array[Object] = []
	for i: int in get_slide_collision_count():
		var col: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider == null or collider in contacted:
			continue
		contacted.append(collider)
		if collider.has_method("on_player_contact"):
			collider.on_player_contact(self, col.get_normal())


func _rotate_mesh(delta: float) -> void:
	var flat := Vector3(_velocity.x, 0.0, _velocity.z)
	if flat.length_squared() > 0.1:
		var target_yaw: float = atan2(flat.x, flat.z)
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_yaw, rotation_speed * delta)
	var normalized_vy: float = clamp(_velocity.y / BOUNCE_FORCE, -1.0, 1.0)
	_mesh.rotation.x = lerp(
		_mesh.rotation.x, -normalized_vy * max_tilt_angle, rotation_speed * delta
	)
