extends Node
const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()
func _ready():
	var err = config.load(SETTINGS_PATH)
	if err == OK: AudioServer.set_bus_volume_db(0, linear_to_db(config.get_value("Audio", "MasterVolume", 0.5)))
	else: save_setting("Audio", "MasterVolume", 0.5)
func save_setting(section: String, key: String, value: Variant):
	config.set_value(section, key, value); 
	config.save(SETTINGS_PATH)
