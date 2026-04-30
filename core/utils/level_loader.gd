class_name LevelLoader
extends RefCounted

## Stateless utility: scans resources/levels/ and returns all LevelData sorted by level_id.

const LEVELS_PATH: String = "res://resources/levels/"


static func load_all() -> Array[LevelData]:
	var levels: Array[LevelData] = []
	var files: PackedStringArray = DirAccess.get_files_at(LEVELS_PATH)
	for file_name: String in files:
		if not file_name.ends_with(".tres") and not file_name.ends_with(".res"):
			continue
		var res: Resource = load(LEVELS_PATH + file_name)
		if res is LevelData:
			levels.append(res as LevelData)
	levels.sort_custom(func(a: LevelData, b: LevelData) -> bool: return a.level_id < b.level_id)
	return levels
