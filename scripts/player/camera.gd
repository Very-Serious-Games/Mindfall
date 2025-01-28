extends Camera3D

@export_range(0.1, 10.0, 0.1) var tilt_speed: float = 5.0 # How fast the tilt adjusts
@export_range(0.0, 45.0, 1.0) var max_tilt_angle: float = 10.0 # Maximum tilt angle in degrees
@export_range(1.0, 20.0, 0.1) var fov_change_speed: float = 8.0
@export_range(1.0, 20.0, 0.5) var dash_fov_increase: float = 35.0

var target_tilt: float = 0.0
var current_tilt: float = 0.0
var default_fov: float
var target_fov: float
var is_dashing: bool = false

func _ready() -> void:
	default_fov = fov
	target_fov = default_fov

func update_tilt(input_vector: Vector2) -> void:
	target_tilt = -input_vector.x * max_tilt_angle

func _process(delta: float) -> void:
	current_tilt = lerp(current_tilt, target_tilt, tilt_speed * delta)
	rotation.z = deg_to_rad(current_tilt)
	
	# Handle FOV changes
	fov = lerp(fov, target_fov, fov_change_speed * delta)

func start_dash_fov() -> void:
	target_fov = default_fov + dash_fov_increase
	is_dashing = true

func end_dash_fov() -> void:
	target_fov = default_fov
	is_dashing = false
