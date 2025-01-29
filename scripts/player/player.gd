class_name Player extends CharacterBody3D

const HIT_STAGGER = 8.0
const FOOTSTEP_TIME = 0.1

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
@export_range(1, 100, 1) var fire_rate: float = 4
@export_range(1, 500, 10) var damage: float = 100
@export_range(1, 1000, 50) var shoot_range: float = 500
@export_range(1, 100, 1) var max_ammo: int = 9
@export_range(0.1, 5.0, 0.1) var reload_time: float = 1.5

@export_category("Transition Effect")
@export var transition_trigger: MeshInstance3D
@export var transition_range: float = 16.0

@onready var raycast: RayCast3D = $Camera/ShootRayCast
@onready var camera: Camera3D = $Camera
@onready var health_bar: ProgressBar = $GUI/HUDContainer/BottomHUDContainer/LeftElements/HealthBar
@onready var health_text: Label = $GUI/HUDContainer/BottomHUDContainer/LeftElements/HealthBar/HealthText
@onready var current_ammo_label: Label = $GUI/HUDContainer/BottomHUDContainer/RightElements/CurrentAmmo
@onready var max_ammo_label: Label = $GUI/HUDContainer/BottomHUDContainer/RightElements/MaxAmmo
@onready var powerup_manager: PowerUpManager = $PowerUpManager
@onready var dash_bar: ProgressBar = $GUI/HUDContainer/BottomHUDContainer/LeftElements/DashBar
@onready var dash_bar_double: HBoxContainer = $GUI/HUDContainer/BottomHUDContainer/LeftElements/DashBarDouble
@onready var dash_bar1: ProgressBar = $GUI/HUDContainer/BottomHUDContainer/LeftElements/DashBarDouble/DashBar1
@onready var dash_bar2: ProgressBar = $GUI/HUDContainer/BottomHUDContainer/LeftElements/DashBarDouble/DashBar2
@onready var death_screen: Control = $GUI/DeathScreenContainer
@onready var postprocessing: ColorRect = $GUI/Postprocesing
@onready var floor_check: RayCast3D = $FloorCheck
@onready var anim_player: AnimationPlayer = $Camera/Player/AnimationPlayer
@onready var anim_tree: AnimationTree = $Camera/Player/AnimationTree

#@onready var grass_node: MultiMeshInstance3D = $"../GrassInstance3D"

signal player_hit
signal body_part_hit

var state_machine: AnimationNodeStateMachinePlayback

var remaining_jumps: int = 1
var remaining_dashes: int = 1
var dash_recharge_timer: float = 0.0
const DASH_RECHARGE_TIME: float = 1.5

var current_ammo: int = max_ammo
var can_shoot: bool = true
var is_reloading: bool = false
var is_shooting: bool = false
var current_health: float = max_health
var is_dead: bool = false

var dash_vel: Vector3
var is_dashing: bool = false
var dash_timer: float = 0.0
var jumping: bool = false
var jump_pressed: bool = false
var mouse_captured: bool = false
var footstep_timer = 0.0

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
	_setup_dash_bars()
	death_screen.hide()
	state_machine = anim_tree.get("parameters/playback")


func _process(_delta: float) -> void:
	health_bar.value = (current_health / max_health) * 100
	health_text.text = "%.0f" % [current_health]
	
	current_ammo_label.text = str(current_ammo)
	max_ammo_label.text = "/%d%s" % [max_ammo, " [R]" if is_reloading else ""]
	
	if health_regen > 0 and current_health < max_health:
		heal(health_regen * _delta)

	_update_dash_bars()
	_update_animations()

func _update_animations() -> void:
	# Handle shooting animation with priority
	if Input.is_action_pressed("shoot") and can_shoot and current_ammo > 0 and not is_reloading:
		is_shooting = true
		anim_tree.set("parameters/conditions/shoot", true)
		# Keep animation playing
		state_machine.travel("Pistol_FIRE")
	else:
		is_shooting = false
		anim_tree.set("parameters/conditions/shoot", false)
		if not is_reloading:
			state_machine.travel("Pistol_IDLE")
	
	# Handle reload animation only if not shooting
	if is_reloading and not is_shooting:
		anim_tree.set("parameters/conditions/reload", true)
	else:
		anim_tree.set("parameters/conditions/reload", false)

func _unhandled_input(event: InputEvent) -> void:
	if is_dead and event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
		return
	if event is InputEventMouseMotion and mouse_captured:
		look_dir = event.relative * 0.001
		_rotate_camera()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_pressed = true
	if Input.is_action_just_released("jump"):
		jump_pressed = false
	if mouse_captured:
		_handle_joypad_camera_rotation(delta)
	camera.update_tilt(move_dir)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta) + _dash(delta)
	move_and_slide()
	_handle_shooting(delta)
	_handle_dash_recharge(delta)
	_handle_transition_effect()
	#push_grass()

func _handle_transition_effect() -> void:
	if transition_trigger:
		# Get player and trigger absolute positions
		var player_pos = global_position
		var trigger_pos = transition_trigger.global_position
		
		# Calculate distance on z-axis only (since it's a vertical trigger)
		var distance = abs(player_pos.z - trigger_pos.z)
		
		if distance <= transition_range:
			# Calculate sort value based on distance of the player clamped between 0 and 2
			var sort_value = clamp(transition_range / distance, 0.0, 5.0)
			update_sort_effect(sort_value)
		else:
			update_sort_effect(0.0)

func update_sort_effect(value: float) -> void:
	if postprocessing and postprocessing.material:
		postprocessing.material.set_shader_parameter("sort", value)

func _handle_dash_recharge(delta: float) -> void:
	if remaining_dashes < powerup_manager.dash_charges:
		dash_recharge_timer += delta
		if dash_recharge_timer >= DASH_RECHARGE_TIME:
			remaining_dashes += 1
			dash_recharge_timer = 0.0

# Modify _handle_shooting function:
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
			# Reset shoot condition before the timeout
			anim_tree.set("parameters/conditions/shoot", false)
			await get_tree().create_timer(1.0 / fire_rate).timeout
			can_shoot = true

func _start_reload() -> void:
	is_reloading = true
	# Trigger reload animation
	anim_tree.set("parameters/conditions/reload", true)
	AudioManager.play_sound_3d("reload_gun", position)
	await get_tree().create_timer(reload_time * powerup_manager.reload_speed_multiplier).timeout
	current_ammo = max_ammo
	is_reloading = false
	# Reset reload condition
	anim_tree.set("parameters/conditions/reload", false)
	
func _shoot() -> void:
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		if raycast.get_collider().is_in_group("enemy"):
			raycast.get_collider().hit()
			emit_signal("body_part_hit")
	
	# Set animation speed based on fire rate
	var anim_speed = fire_rate / 2.0
	anim_tree.set("parameters/Pistol_FIRE/TimeScale", anim_speed)
	anim_tree.advance(0.3) # Force animation to complete at 0.3s
	
	anim_tree.set("parameters/conditions/shoot", true)

func _rotate_camera(sens_mod: float = 1.0) -> void:
	var sensitivity = Settings.settings.gameplay.mouse_sensitivity
	# Fix: Use look_dir.x for horizontal rotation (player)
	rotate_y(-look_dir.x * camera_sens * sensitivity * sens_mod)
	# Keep look_dir.y for vertical rotation (camera only)
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sensitivity * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# Get camera's forward direction (excluding vertical component)
	var cam_basis = camera.global_transform.basis
	var forward = cam_basis.z  # Removed negative sign here
	forward.y = 0
	forward = forward.normalized()
	
	# Get camera's right direction
	var right = cam_basis.x
	right.y = 0
	right = right.normalized()
	
	# Calculate movement direction relative to camera
	var walk_dir = (forward * move_dir.y + right * move_dir.x).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	
	if is_on_floor() and move_dir.length():
		footstep_timer += delta
		if footstep_timer >= FOOTSTEP_TIME:
			footstep_timer = 0.0
			_play_footstep()

	return walk_vel
	
func _play_footstep() -> void:
	if floor_check and floor_check.is_colliding():
		var collider = floor_check.get_collider()
		if collider.is_in_group("grass") or collider.is_in_group("dirt"):
			AudioManager.play_sound_3d("outdoor_footstep", position)
		else:
			AudioManager.play_sound_3d("footstep", position)
	else:
		AudioManager.play_sound_3d("footstep", position)

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if is_on_floor():
		remaining_jumps = powerup_manager.max_jumps
		if not jump_pressed:
			jump_vel = Vector3.ZERO

	if jump_pressed and remaining_jumps > 0:
		jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		remaining_jumps -= 1
		AudioManager.play_sound_3d("jump", position)
		jump_pressed = false
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
			dash_vel = -global_transform.basis.z * dash_speed
		camera.start_dash_fov()
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
	death_screen.show()
	set_player_controls_enabled(false)

func set_player_controls_enabled(enabled: bool) -> void:
	set_physics_process(enabled)
	set_process_input(enabled)
	camera.set_process(enabled)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir = joypad_dir * delta
		_rotate_camera(sens_mod)

func hit(dir, damage: float = 1) -> void:
	emit_signal("player_hit") # check if needed
	velocity = dir * HIT_STAGGER
	take_damage(damage)

func _setup_dash_bars() -> void:
	# Set visibility based on double dash powerup
	var has_double_dash = PowerUp.PowerUpType.DOUBLE_DASH in powerup_manager.active_powerups
	dash_bar.visible = !has_double_dash
	dash_bar_double.visible = has_double_dash

func _update_dash_bars() -> void:
	if PowerUp.PowerUpType.DOUBLE_DASH in powerup_manager.active_powerups:
		dash_bar.visible = false
		dash_bar_double.visible = true
		
		# First dash bar (left) - represents first dash
		if remaining_dashes >= 1:
			dash_bar1.value = 100.0
		else:
			dash_bar1.value = (dash_recharge_timer / DASH_RECHARGE_TIME) * 100
		
		# Second dash bar (right) - represents second dash
		if remaining_dashes >= 2:
			dash_bar2.value = 100.0
		elif remaining_dashes == 1:
			dash_bar2.value = (dash_recharge_timer / DASH_RECHARGE_TIME) * 100
		else:
			dash_bar2.value = 0.0
	else:
		dash_bar.visible = true
		dash_bar_double.visible = false
		var recharge_progress = (dash_recharge_timer / DASH_RECHARGE_TIME) * 100
		dash_bar.value = 100.0 if remaining_dashes >= 1 else recharge_progress

#func push_grass():
#	grass_node.set_deferred("instance_shader_parameters/player_position", position + Vector3(0, -0.1, 0))
