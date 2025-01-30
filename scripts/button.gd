extends StaticBody3D

@export var good_ending: bool = true
@export_file("*.tscn") var good_ending_scene: String
@export_file("*.tscn") var bad_ending_scene: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:  # Only trigger for player
		animation_player.play("pressdown")
		var target_scene = good_ending_scene if good_ending else bad_ending_scene
		if target_scene:
			get_tree().change_scene_to_file(target_scene)
		else:
			push_warning("No scene path set for button!")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:  # Only trigger for player
		animation_player.play("pressup")
