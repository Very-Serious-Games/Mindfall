extends StaticBody3D

@export_file("*.tscn") var next_scene_path: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_3d_body_entered(body: Node3D) -> void:
	animation_player.play("pressdown")
	if next_scene_path:
		get_tree().change_scene_to_file(next_scene_path)
	else:
		push_warning("No scene path set for button!")

func _on_area_3d_body_exited(body: Node3D) -> void:
	animation_player.play("pressup")
