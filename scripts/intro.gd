extends Node3D

@export_file("*.tscn") var next_scene_path: String

@onready var armature: Node3D = $Armature
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gui: Control = $GUI
@onready var postprocessing: ColorRect = $GUI/Postprocesing

func _ready() -> void:
	animation_player.play("Suicide")
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	pass

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Suicide":
		_start_transition()

func _start_transition() -> void:
	var tween = create_tween()
	# Interpolate sort parameter from 0 to 5 over 2 seconds
	tween.tween_method(_update_sort_effect, 0.0, 5.0, 2.0)
	tween.tween_callback(_change_scene)

func _update_sort_effect(value: float) -> void:
	if postprocessing and postprocessing.material:
		postprocessing.material.set_shader_parameter("sort", value)

func _change_scene() -> void:
	if next_scene_path:
		get_tree().change_scene_to_file(next_scene_path)
	else:
		push_warning("No next scene path set!")
