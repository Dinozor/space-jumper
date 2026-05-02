class_name SaveManager

const SAVE_PATH: String = "user://progression.json"
const SCORES_PATH: String = "user://scores.json"
const _MAX_SCORES: int = 20


static func save_progression() -> void:
	var data: Dictionary = {
		"currency": GameState.currency,
		"current_character": GameState.current_character,
		"unlocked_levels": GameState.unlocked_levels,
		"unlocked_characters": GameState.unlocked_characters,
		"purchased_abilities": GameState.purchased_abilities,
		"character_upgrades": GameState.character_upgrades,
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


static func load_progression() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed as Dictionary
	if "currency" in data:
		GameState.currency = int(data["currency"])
	if "current_character" in data:
		GameState.current_character = str(data["current_character"])
	if "unlocked_levels" in data:
		GameState.unlocked_levels.clear()
		for v: Variant in data["unlocked_levels"]:
			GameState.unlocked_levels.append(int(v))
	if "unlocked_characters" in data:
		GameState.unlocked_characters.clear()
		for v: Variant in data["unlocked_characters"]:
			GameState.unlocked_characters.append(str(v))
	if "purchased_abilities" in data:
		GameState.purchased_abilities.clear()
		for v: Variant in data["purchased_abilities"]:
			GameState.purchased_abilities.append(str(v))
	if "character_upgrades" in data:
		GameState.character_upgrades = data["character_upgrades"] as Dictionary


static func delete_progression() -> void:
	_delete_file(SAVE_PATH)
	GameState.currency = 0
	GameState.current_character = "penguin"
	GameState.unlocked_levels.clear()
	GameState.unlocked_levels.append(0)
	GameState.unlocked_characters.clear()
	GameState.unlocked_characters.append("penguin")
	GameState.purchased_abilities.clear()
	GameState.character_upgrades.clear()


static func save_scores() -> void:
	var file: FileAccess = FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(GameState.scoreboard, "\t"))
	file.close()


static func load_scores() -> void:
	if not FileAccess.file_exists(SCORES_PATH):
		return
	var file: FileAccess = FileAccess.open(SCORES_PATH, FileAccess.READ)
	if file == null:
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		GameState.scoreboard = parsed as Dictionary


static func delete_scores() -> void:
	_delete_file(SCORES_PATH)
	GameState.scoreboard.clear()


static func _delete_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var dir: DirAccess = DirAccess.open(path.get_base_dir())
	if dir != null:
		dir.remove(path.get_file())
