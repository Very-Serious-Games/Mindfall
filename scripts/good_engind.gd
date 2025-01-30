extends Node3D

@export_file("*.tscn") var credits_scene: String

@onready var armature: Node3D = $Armature
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gui: Control = $GUI
@onready var postprocessing: ColorRect = $GUI/Postprocesing

func _ready() -> void:
	animation_player.play_backwards("Suicide")
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	pass

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Suicide":
		_start_transition()

func _start_transition() -> void:
	var tween = create_tween()
	tween.tween_method(_update_sort_effect, 0.0, 5.0, 2.0)
	tween.tween_callback(func():
		if credits_scene:
			get_tree().change_scene_to_file(credits_scene)
		else:
			push_warning("No credits scene path set!"))

func _update_sort_effect(value: float) -> void:
	if postprocessing and postprocessing.material:
		postprocessing.material.set_shader_parameter("sort", value)
