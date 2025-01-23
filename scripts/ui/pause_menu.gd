extends Control

var is_paused: bool = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED
		
func _ready():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		is_paused = !is_paused

func _on_resume_button_pressed():
	is_paused = false

func _on_options_button_pressed():
	is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")

func _on_quit_button_pressed():
	is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
