extends RefCounted
class_name SaveGame

const SAVE_GAME_PATH: NodePath = "user://save.json"

var json = JSON.new()

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)
	
func write_save_game() -> void:
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if file == null:
		printerr("Could not open save game %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, FileAccess.get_open_error()])
		return
	
	# TODO: just pass Globals here?
	var data: Dictionary = {
		"game_version": Globals.game_version,
		"high_score": Globals.high_score
	}
	
	var json_string = JSON.stringify(data)
	file.store_line(json_string)
	file.close()

func load_save_game() -> void:
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if file == null:
		printerr("Could not open save game %s. Aborting load operation. Error code: %s" % [SAVE_GAME_PATH, FileAccess.get_open_error()])
		return
	
	var content = file.get_line()
	file.close()
	
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		
		if typeof(data) == TYPE_DICTIONARY:
			#print("save data, ", data)

			# TODO: Feels like there's a better way to handle this
			# especially as there's more [complex] data to load...
			Globals.high_score = data.high_score
		else:
			printerr("Unexpected data from save game, %" % data)
	else:
		printerr("JSON parse error %s in %s at line %s" % [json.get_error_message(), content, json.get_error_line()])
	
