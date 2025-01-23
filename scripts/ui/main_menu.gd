extends Control

func play_button_sound() -> void:
	var sounds = ["button_click_1", "button_click_2", "button_click_3", "button_click_4"]
	var random_sound = sounds[randi() % sounds.size()]
	AudioManager.play_sound_3d(random_sound, Vector3.ZERO)

func _on_start_button_pressed() -> void:
	play_button_sound()
	get_tree().change_scene_to_file("res://scenes/levels/playground.tscn")

func _on_options_button_pressed() -> void:
	play_button_sound()
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")

func _on_quit_button_pressed() -> void:
	play_button_sound()
	get_tree().quit()
