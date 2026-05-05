class_name LevelLoader
extends RefCounted

## Stateless utility: returns all LevelData sorted by level_id.
## Explicit paths required — DirAccess directory scanning does not work in web exports.

const _PATHS: Array[String] = [
	"res://resources/levels/bridge.tres",
	"res://resources/levels/cargo_bay.tres",
	"res://resources/levels/command_deck.tres",
	"res://resources/levels/enemy_ship.tres",
	"res://resources/levels/hull_section.tres",
	"res://resources/levels/reactor_core.tres",
]


static func load_all() -> Array[LevelData]:
	var levels: Array[LevelData] = []
	for path: String in _PATHS:
		var res: Resource = load(path)
		if res is LevelData:
			levels.append(res as LevelData)
	levels.sort_custom(func(a: LevelData, b: LevelData) -> bool: return a.level_id < b.level_id)
	return levels
