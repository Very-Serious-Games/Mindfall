class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

@export_range(1, 50, 1) var dash_speed: float = 25 # m/s
@export_range(0.1, 1.0, 0.1) var dash_duration: float = 0.2 # seconds

@export_category("Health")
@export_range(1, 1000, 10) var max_health: float = 100
@export_range(0.1, 10.0, 0.1) var health_regen: float = 0.0
@export var invulnerable: bool = false

@export_category("Shooting")
@export_range(10, 100, 1) var fire_rate: float = 4 # Shots per second
@export_range(50, 500, 10) var damage: float = 100 # Damage per shot
@export_range(100, 1000, 50) var shoot_range: float = 500 # Max shooting distance
@export_range(1, 100, 1) var max_ammo: int = 30
@export_range(0.1, 5.0, 0.1) var reload_time: float = 1.5

@onready var raycast: RayCast3D = $Camera/ShootRayCast
@onready var camera: Camera3D = $Camera
@onready var health_bar: ProgressBar = $GUI/HUDContainer/HealthBar
@onready var health_text: Label = $GUI/HUDContainer/HealthBar/HealthText
@onready var ammo_counter: Label = $GUI/HUDContainer/AmmoCounter
@onready var powerup_manager: PowerUpManager = $PowerUpManager

signal enemy_hit

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

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity


func _ready() -> void:
	add_to_group("player")
	
	capture_mouse()
	
	current_health = max_health

	remaining_jumps = powerup_manager.max_jumps
	remaining_dashes = powerup_manager.dash_charges

	raycast.enabled = true
	raycast.target_position = Vector3(0, 0, -shoot_range)
	raycast.collision_mask = 1

# Add this for debug visualization
func _process(_delta: float) -> void:
	# Update HUD elements
	health_bar.value = (current_health / max_health) * 100
	health_text.text = "%.0f/%.0f" % [current_health, max_health]
	
	if Input.is_action_just_pressed("debug_damage"):
		take_damage(10)
	
	var ammo_text = "%d/%d" % [current_ammo, max_ammo]
	if is_reloading:
		ammo_text += " [R]"
	ammo_counter.text = ammo_text

	if health_regen > 0 and current_health < max_health:
		heal(health_regen * _delta)

	if Input.is_action_pressed("shoot") and can_shoot and current_ammo > 0:
		var debug_length = -shoot_range
		var start = raycast.global_position
		var end = start + raycast.global_transform.basis.z * debug_length
		DebugDraw3D.draw_line(start, end, Color.RED)

		if raycast.is_colliding():
			var hit_point = raycast.get_collision_point()
			DebugDraw3D.draw_sphere(hit_point, 0.1, Color.GREEN)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true

func _physics_process(delta: float) -> void:
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	camera.update_tilt(move_dir)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta) + _dash(delta)
	move_and_slide()
	_handle_shooting(delta)
	_handle_dash_recharge(delta)

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
			for i in powerup_manager.burst_shot_count:
				_shoot()
				await get_tree().create_timer(0.1).timeout
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
		var hit_point = raycast.get_collision_point()
		var hit_object = raycast.get_collider()

		AudioManager.play_sound_3d("shoot", position)

		if hit_object.has_method("take_damage"):
			hit_object.take_damage(damage)
			emit_signal("enemy_hit")
		
		# Optional: Visual/audio feedback
		_spawn_hit_effect(raycast.get_collision_point())
		
func _spawn_hit_effect(hit_point: Vector3) -> void:
	# Placeholder for hit particle or decal
	pass

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	var sensitivity = Settings.settings.gameplay.mouse_sensitivity
	camera.rotation.y -= look_dir.x * camera_sens * sensitivity * sens_mod  
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sensitivity * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	
	if move_dir.length() > 0 and is_on_floor():
		AudioManager.play_sound_3d("footstep", position)
	
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	# Reset jumps when touching floor
	if is_on_floor():
		remaining_jumps = powerup_manager.max_jumps

		# Only reset velocity when landing, not for new jumps
		if not jumping:
			jump_vel = Vector3.ZERO

	# Process jump input
	if jumping:
		if remaining_jumps > 0:
			jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
			remaining_jumps -= 1
			AudioManager.play_sound_3d("jump", position)
		jumping = false  # Clear the jump input immediately after processing
	else:
		# Apply gravity when not jumping
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
		AudioManager.play_sound_3d("dash", position)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_vel = Vector3.ZERO
	
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
	if is_dead:
		return
	current_health = minf(max_health, current_health + amount)

func die() -> void:
	is_dead = true
	AudioManager.play_sound_3d("death", position)
	# Implement death behavior (e.g., respawn, game over, etc.)
	release_mouse()
