extends Node3D

@onready var level_music = preload("res://assets/audio/music/Sxnctuary.ogg")

func _ready() -> void:
	AudioManager.play_music(level_music)

func _exit_tree() -> void:
	AudioManager.music_player.stop()
