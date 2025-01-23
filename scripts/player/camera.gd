extends Camera3D

@export_range(0.1, 10.0, 0.1) var tilt_speed: float = 5.0 # How fast the tilt adjusts
@export_range(0.0, 45.0, 1.0) var max_tilt_angle: float = 10.0 # Maximum tilt angle in degrees

var target_tilt: float = 0.0 # The desired tilt angle
var current_tilt: float = 0.0 # The current tilt angle

# Call this method from the player controller to update the tilt
func update_tilt(input_vector: Vector2) -> void:
	# Calculate tilt based on lateral movement (x-axis of input_vector)
	target_tilt = -input_vector.x * max_tilt_angle

func _process(delta: float) -> void:
	# Smoothly interpolate current tilt towards target tilt
	current_tilt = lerp(current_tilt, target_tilt, tilt_speed * delta)
	# Apply the tilt as a roll rotation
	rotation.z = deg_to_rad(current_tilt)
