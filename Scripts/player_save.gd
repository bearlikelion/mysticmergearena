class_name PlayerSave
extends Resource

@export var uuid: String = ""

static var file_name: String = "player_save"

static func get_save_path() -> String:
	return "user://" + file_name + ".res"


static func has_player_data() -> bool:
	var SAVE_PATH: String = get_save_path()
	if ResourceLoader.exists(SAVE_PATH):
		return true
	else:
		return false


static func load_player_data() -> PlayerSave:
	print("File Name: %s" % file_name)
	var SAVE_PATH: String = get_save_path()
	if ResourceLoader.exists(SAVE_PATH):
		print("Loaded player data for %s" % file_name)
		var player_save: PlayerSave = ResourceLoader.load(SAVE_PATH)
		if player_save is PlayerSave:
			return player_save
	else:
		print("No Save file found for %s, creating one" % file_name)
		var player_save = new()
		player_save.uuid = Global.device_id
		player_save.save_player_data(player_save)
	return null


func save_player_data(data: PlayerSave) -> void:
	print("Save player data")
	var SAVE_PATH: String = PlayerSave.get_save_path()
	var result: Error = ResourceSaver.save(data, SAVE_PATH, ResourceSaver.FLAG_COMPRESS)
	assert(result == OK)
