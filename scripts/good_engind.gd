extends Node3D

@onready var armature: Node3D = $Armature
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gui: Control = $GUI
@onready var postprocessing: ColorRect = $GUI/Postprocesing

func _ready() -> void:
	animation_player.play_backwards("Suicide")

func _process(delta: float) -> void:
	pass

func _start_transition() -> void:
	var tween = create_tween()
	# Interpolate sort parameter from 0 to 5 over 2 seconds
	tween.tween_method(_update_sort_effect, 0.0, 5.0, 2.0)

func _update_sort_effect(value: float) -> void:
	if postprocessing and postprocessing.material:
		postprocessing.material.set_shader_parameter("sort", value)
