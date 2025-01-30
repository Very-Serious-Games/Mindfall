extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")
	
func _on_credits_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")

func _on_tutorial_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_quit_button_pressed() -> void:
	AudioManager.play_ui_sound("menu_select")
	get_tree().quit()
