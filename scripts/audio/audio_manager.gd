extends Node

# Bus indices
var master_bus: int
var music_bus: int
var sfx_bus: int

# Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer3D] = []
var ui_players: Array[AudioStreamPlayer] = []

var active_sounds: Dictionary = {}

# Preloaded sounds
var sounds = {
	# Combat sounds
	"shoot": preload("res://assets/audio/sfx/shoot.wav"),
	"gun_click": preload("res://assets/audio/sfx/gun_click.wav"),
	"reload_gun": preload("res://assets/audio/sfx/reload_gun.wav"),
	"headshot": preload("res://assets/audio/sfx/Headshot.wav"),
	"hit": preload("res://assets/audio/sfx/Hit.wav"),
	"enemy_death": preload("res://assets/audio/sfx/EnemyDeath.wav"),

	# Movement sounds
	"footstep": preload("res://assets/audio/sfx/footstep.wav"),
	"outdoor_footstep": preload("res://assets/audio/sfx/FootstepsGrass.wav"),
	"dash": preload("res://assets/audio/sfx/dash.wav"),

	# Menu sounds
	"menu_select": preload("res://assets/audio/sfx/menu_select.wav"),

	# Misc
	"pickup_item": preload("res://assets/audio/sfx/pickup_item.wav"),
	"vanish": preload("res://assets/audio/sfx/vanish.wav")
}

func _ready():
	# Ensure audio busses exist
	create_bus_if_missing("Music")
	create_bus_if_missing("SFX")
	
	# Initialize bus indices
	master_bus = get_bus_index_safe("Master")
	music_bus = get_bus_index_safe("Music")
	sfx_bus = get_bus_index_safe("SFX")
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Initialize SFX player pool
	for i in range(5):
		var player = AudioStreamPlayer3D.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

	# Initialize UI player pool
	for i in range(3):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		ui_players.append(player)

func play_ui_sound(sound_name: String):
	if not sounds.has(sound_name):
		return

	# Find free player and play sound
	for player in ui_players:
		if not player.playing:
			player.stream = sounds[sound_name]
			player.play()
			return

func create_bus_if_missing(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var bus_count = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(bus_count, bus_name)
		AudioServer.set_bus_send(bus_count, "Master")

func get_bus_index_safe(bus_name: String) -> int:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_error("Audio bus '%s' not found!" % bus_name)
	return idx

func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_error("Cannot set volume: Audio bus '%s' not found!" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))
	print("Set %s bus volume to: %.2f (%.2f dB)" % [bus_name, volume, linear_to_db(volume)])

func play_music(stream: AudioStream, crossfade_duration: float = 1.0):
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, crossfade_duration)
		tween.tween_callback(func():
			music_player.stream = stream
			music_player.volume_db = 0
			music_player.play()
		)
	else:
		music_player.stream = stream
		music_player.play()

func play_sound_3d(sound_name: String, position: Vector3):
	if not sounds.has(sound_name):
		return
	
	# Check if sound is already playing
	if active_sounds.has(sound_name):
		for player_info in active_sounds[sound_name]:
			if player_info.playing:
				return
		active_sounds.erase(sound_name)
	
	# Find free player and play sound
	for player in sfx_players:
		if not player.playing:
			player.stream = sounds[sound_name]
			player.position = position
			player.play()
			
			# Track the active sound
			if not active_sounds.has(sound_name):
				active_sounds[sound_name] = []
			active_sounds[sound_name].append(player)
			
			# Connect finished signal to cleanup
			player.finished.connect(
				func(): _on_sound_finished(sound_name, player),
				CONNECT_ONE_SHOT
			)
			return

func _on_sound_finished(sound_name: String, player: AudioStreamPlayer3D) -> void:
	if active_sounds.has(sound_name):
		active_sounds[sound_name].erase(player)
		if active_sounds[sound_name].is_empty():
			active_sounds.erase(sound_name)
