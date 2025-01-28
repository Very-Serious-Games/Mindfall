extends Area3D

@export_file("*.tscn") var next_scene: String  # Path to next scene
var transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player and not transitioning:
		transitioning = true
		call_deferred("_transition_to_next_scene")

func _transition_to_next_scene() -> void:
	if next_scene:
		get_tree().call_deferred("change_scene_to_file", next_scene)
