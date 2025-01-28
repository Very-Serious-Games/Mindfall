class_name Player extends CharacterBody3D

const HIT_STAGGER = 8.0

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10
@export_range(10, 400, 1) var acceleration: float = 100
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1
@export_range(0.1, 3.0, 0.1) var camera_sens: float = 1
@export_range(1, 50, 1) var dash_speed: float = 25
@export_range(0.1, 1.0, 0.1) var dash_duration: float = 0.2

@export_category("Health")
@export_range(1, 1000, 10) var max_health: float = 100
@export_range(0.1, 10.0, 0.1) var health_regen: float = 0.0
@export var invulnerable: bool = false

@export_category("Shooting")
@export_range(10, 100, 1) var fire_rate: float = 4
@export_range(50, 500, 10) var damage: float = 100
@export_range(100, 1000, 50) var shoot_range: float = 500
@export_range(1, 100, 1) var max_ammo: int = 30
@export_range(0.1, 5.0, 0.1) var reload_time: float = 1.5

@onready var raycast: RayCast3D = $Camera/ShootRayCast
@onready var camera: Camera3D = $Camera
@onready var health_bar: ProgressBar = $GUI/HUDContainer/HealthBar
@onready var health_text: Label = $GUI/HUDContainer/HealthBar/HealthText
@onready var ammo_counter: Label = $GUI/HUDContainer/AmmoCounter
@onready var powerup_manager: PowerUpManager = $PowerUpManager
#@onready var grass_node: MultiMeshInstance3D = $"../GrassInstance3D"

signal player_hit
signal body_part_hit

var remaining_jumps: int = 1
var remaining_dashes: int = 1
var dash_recharge_timer: float = 0.0
const DASH_RECHARGE_TIME: float = 1.5

var current_ammo: int = max_ammo
var can_shoot: bool = true
var is_reloading: bool = false
var current_health: float = max_health
var is_dead: bool = false

var dash_vel: Vector3
var is_dashing: bool = false
var dash_timer: float = 0.0
var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_dir: Vector2
var look_dir: Vector2
var walk_vel: Vector3
var grav_vel: Vector3
var jump_vel: Vector3

func _ready() -> void:
	capture_mouse()
	current_health = max_health
	remaining_jumps = powerup_manager.max_jumps
	remaining_dashes = powerup_manager.dash_charges
	raycast.target_position = Vector3(0, 0, -shoot_range)

func _process(_delta: float) -> void:
	health_bar.value = (current_health / max_health) * 100
	health_text.text = "%.0f" % [current_health]
	ammo_counter.text = "%d/%d%s" % [current_ammo, max_ammo, " [R]" if is_reloading else ""]
	
	if health_regen > 0 and current_health < max_health:
		heal(health_regen * _delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured:
		look_dir = event.relative * 0.001
		_rotate_camera()
	if Input.is_action_just_pressed("jump"): 
		jumping = true

func _physics_process(delta: float) -> void:
	if mouse_captured:
		_handle_joypad_camera_rotation(delta)
	camera.update_tilt(move_dir)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta) + _dash(delta)
	move_and_slide()
	_handle_shooting(delta)
	_handle_dash_recharge(delta)
	#push_grass()

func _handle_dash_recharge(delta: float) -> void:
	if remaining_dashes < powerup_manager.dash_charges:
		dash_recharge_timer += delta
		if dash_recharge_timer >= DASH_RECHARGE_TIME:
			remaining_dashes += 1
			dash_recharge_timer = 0.0

func _handle_shooting(delta: float) -> void:
	if Input.is_action_just_pressed("reload") and not is_reloading and current_ammo < max_ammo:
		_start_reload()
		return

	if Input.is_action_just_pressed("shoot"):
		if current_ammo <= 0:
			AudioManager.play_sound_3d("gun_click", position)
			return
		if can_shoot and not is_reloading:
			AudioManager.play_sound_3d("shoot", position)
			_shoot()
			current_ammo -= 1
			can_shoot = false
			await get_tree().create_timer(1.0 / fire_rate).timeout
			can_shoot = true

func _start_reload() -> void:
	is_reloading = true
	AudioManager.play_sound_3d("reload_gun", position)
	await get_tree().create_timer(reload_time * powerup_manager.reload_speed_multiplier).timeout
	current_ammo = max_ammo
	is_reloading = false

func _shoot() -> void:
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		if raycast.get_collider().is_in_group("enemy"):
			#AudioManager.play_sound_3d("hit_enemy", position)
			raycast.get_collider().hit()
			emit_signal("body_part_hit")

func _rotate_camera(sens_mod: float = 1.0) -> void:
	var sensitivity = Settings.settings.gameplay.mouse_sensitivity
	camera.rotation.y -= look_dir.x * camera_sens * sensitivity * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sensitivity * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if is_on_floor():
		remaining_jumps = powerup_manager.max_jumps
		if not jumping:
			jump_vel = Vector3.ZERO

	if jumping and remaining_jumps > 0:
		jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		remaining_jumps -= 1
		AudioManager.play_sound_3d("jump", position)
		jumping = false
	else:
		jump_vel = jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _dash(delta: float) -> Vector3:
	if Input.is_action_just_pressed("dash") and not is_dashing and remaining_dashes > 0:
		is_dashing = true
		remaining_dashes -= 1
		dash_timer = dash_duration
		dash_vel = velocity.normalized() * dash_speed
		if dash_vel == Vector3.ZERO:
			dash_vel = camera.global_transform.basis.z * -1 * dash_speed
		camera.start_dash_fov() # Add this line
		AudioManager.play_sound_3d("dash", position)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_vel = Vector3.ZERO
			camera.end_dash_fov() # Add this line
	return dash_vel if is_dashing else Vector3.ZERO

func take_damage(amount: float) -> void:
	if invulnerable or is_dead:
		return
	current_health = maxf(0, current_health - amount)
	if current_health <= 0:
		die()
	else:
		AudioManager.play_sound_3d("hurt", position)

func heal(amount: float) -> void:
	if not is_dead:
		current_health = minf(max_health, current_health + amount)

func die() -> void:
	is_dead = true
	AudioManager.play_sound_3d("death", position)
	release_mouse()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func hit(dir, damage: float = 1) -> void:
	emit_signal("player_hit") # check if needed
	velocity = dir * HIT_STAGGER
	take_damage(damage)
	
#func push_grass():
#	grass_node.set_deferred("instance_shader_parameters/player_position", position + Vector3(0, -0.1, 0))
