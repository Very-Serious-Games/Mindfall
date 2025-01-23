extends Node

const SAVE_PATH = "res://settings.cfg"
var config = ConfigFile.new()

var settings = {
	"audio": {
		"master": 1.0,
		"music": 1.0,
		"effects": 1.0
	},
	"video": {
		"fullscreen": false,
		"vsync": true,
		"quality": 1
	},
	"gameplay": {
		"mouse_sensitivity": 1.0
	}
}

func _ready():
	load_settings()
	setup_audio_buses()
	apply_settings()
	print("Settings file location: ", OS.get_user_data_dir() + "/settings.cfg")

func setup_audio_buses():
	# Ensure audio buses exist
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(1, "Music")
	if AudioServer.get_bus_index("Effects") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(2, "Effects")

func save_settings():
	for section in settings.keys():
		for key in settings[section]:
			config.set_value(section, key, settings[section][key])
	config.save(SAVE_PATH)

func load_settings():
	var error = config.load(SAVE_PATH)
	if error != OK:
		return
	
	for section in settings.keys():
		for key in settings[section]:
			if config.has_section_key(section, key):
				settings[section][key] = config.get_value(section, key)

func apply_settings():
	# Apply audio settings
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.audio.master))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(settings.audio.music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(settings.audio.effects))
	
	# Apply video settings
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.video.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.video.vsync else DisplayServer.VSYNC_DISABLED)
