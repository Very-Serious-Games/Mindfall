extends Control

func _on_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/levels/bad_engind.tscn")
