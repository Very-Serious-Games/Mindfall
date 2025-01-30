extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/levels/good_engind.tscn")
