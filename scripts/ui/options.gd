extends Control

@onready var master_slider = $MarginContainer/TabContainer/Audio/VBoxContainer/MasterVolume/HSlider
@onready var music_slider = $MarginContainer/TabContainer/Audio/VBoxContainer/MusicVolume/HSlider
@onready var effects_slider = $MarginContainer/TabContainer/Audio/VBoxContainer/EffectsVolume/HSlider
@onready var fullscreen_option = $MarginContainer/TabContainer/Video/VBoxContainer/DisplayMode/OptionButton
@onready var vsync_toggle = $MarginContainer/TabContainer/Video/VBoxContainer/VSync
@onready var quality_option = $MarginContainer/TabContainer/Video/VBoxContainer/Quality/OptionButton
@onready var sensitivity_slider = $MarginContainer/TabContainer/Gameplay/VBoxContainer/MouseSensitivity/HSlider

func _ready():
	load_current_settings()

func load_current_settings():
	# Load values from Settings singleton to UI
	master_slider.value = Settings.settings.audio.master
	music_slider.value = Settings.settings.audio.music
	effects_slider.value = Settings.settings.audio.effects
	fullscreen_option.selected = 1 if Settings.settings.video.fullscreen else 0
	vsync_toggle.button_pressed = Settings.settings.video.vsync
	quality_option.selected = Settings.settings.video.quality
	sensitivity_slider.value = Settings.settings.gameplay.mouse_sensitivity

func _on_master_volume_changed(value):
	Settings.settings.audio.master = value
	Settings.apply_settings()
	Settings.save_settings()

func _on_music_volume_changed(value):
	Settings.settings.audio.music = value
	Settings.apply_settings()
	Settings.save_settings()

func _on_effects_volume_changed(value):
	Settings.settings.audio.effects = value
	Settings.apply_settings()
	Settings.save_settings()

func _on_display_mode_changed(index):
	Settings.settings.video.fullscreen = index == 1
	Settings.apply_settings()
	Settings.save_settings()

func _on_vsync_toggled(button_pressed):
	Settings.settings.video.vsync = button_pressed
	Settings.apply_settings()
	Settings.save_settings()

func _on_quality_changed(index):
	Settings.settings.video.quality = index
	Settings.apply_settings()
	Settings.save_settings()

func _on_mouse_sensitivity_changed(value):
	Settings.settings.gameplay.mouse_sensitivity = value
	Settings.save_settings()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
