extends Node3D

@export_file("*.tscn") var credits_scene: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_overlay: ColorRect = $GUI/FadeOverlay

func _ready() -> void:
	animation_player.play("Suicide")
	# Initialize fade overlay as transparent
	fade_overlay.color = Color(0, 0, 0, 0)

func _process(delta: float) -> void:
	pass

func start_ending_transition() -> void:
	var tween = create_tween()
	# Fade to black
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 2.0)
	# Play gunshot at the end of fade
	tween.tween_callback(func(): 
		AudioManager.play_sound_3d("shoot", Vector3.ZERO))
	# Wait a moment after the sound
	tween.tween_interval(0.5)
	# Change to credits scene
	tween.tween_callback(func():
		if credits_scene:
			get_tree().change_scene_to_file(credits_scene)
		else:
			push_warning("No credits scene path set!"))
