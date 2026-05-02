extends Node

## Global game state: score, lives, unlocks, current level, economy, characters.

const CHARACTERS_PATH: String = "res://resources/characters/"
const ABILITIES_PATH: String = "res://resources/abilities/"

var score: int = 0
var lives: int = 3
var current_level: int = 0
var attempt_count: int = 0
var last_attempt_level_id: int = -1
var unlocked_levels: Array[int] = [0]
var levels: Array[LevelData] = []

var currency: int = 0
var purchased_abilities: Array[String] = []
var current_character: String = "penguin"
var unlocked_characters: Array[String] = ["penguin"]
var characters: Array[CharacterData] = []
var abilities: Array[AbilityData] = []
## Upgrade tiers per stat per character: {"penguin": {"move_speed": 2, ...}}
var character_upgrades: Dictionary = {}


func _ready() -> void:
	levels = LevelLoader.load_all()
	characters = _load_characters()
	abilities = _load_abilities()


func get_ability_data(ability_id: String) -> AbilityData:
	for ab: AbilityData in abilities:
		if ab.ability_id == ability_id:
			return ab
	return null


func get_current_character() -> CharacterData:
	for c: CharacterData in characters:
		if c.character_id == current_character:
			return c
	return null


func get_upgrade_tier(character_id: String, stat: String) -> int:
	if character_id not in character_upgrades:
		return 0
	return character_upgrades[character_id].get(stat, 0)


func upgrade_stat(character_id: String, stat: String, cost: int) -> bool:
	var char_data: CharacterData = _find_character(character_id)
	if char_data == null:
		return false
	var tier: int = get_upgrade_tier(character_id, stat)
	if tier >= char_data.max_upgrades_per_stat or currency < cost:
		return false
	currency -= cost
	if character_id not in character_upgrades:
		character_upgrades[character_id] = {}
	character_upgrades[character_id][stat] = tier + 1
	return true


func unlock_next_level(completed_level_id: int) -> void:
	for level: LevelData in levels:
		if level.level_id == completed_level_id + 1 and level.level_id not in unlocked_levels:
			unlocked_levels.append(level.level_id)
			return


func purchase_ability(ability_id: String, cost: int) -> bool:
	if currency < cost or ability_id in purchased_abilities:
		return false
	currency -= cost
	purchased_abilities.append(ability_id)
	return true


func unlock_character(character_id: String, cost: int) -> bool:
	if currency < cost or character_id in unlocked_characters:
		return false
	currency -= cost
	unlocked_characters.append(character_id)
	return true


func _load_characters() -> Array[CharacterData]:
	var result: Array[CharacterData] = []
	var files: PackedStringArray = DirAccess.get_files_at(CHARACTERS_PATH)
	for file_name: String in files:
		if not file_name.ends_with(".tres"):
			continue
		var res: Resource = load(CHARACTERS_PATH + file_name)
		if res is CharacterData:
			result.append(res as CharacterData)
	return result


func _load_abilities() -> Array[AbilityData]:
	var result: Array[AbilityData] = []
	var files: PackedStringArray = DirAccess.get_files_at(ABILITIES_PATH)
	for file_name: String in files:
		if not file_name.ends_with(".tres"):
			continue
		var res: Resource = load(ABILITIES_PATH + file_name)
		if res is AbilityData:
			result.append(res as AbilityData)
	return result


func _find_character(character_id: String) -> CharacterData:
	for c: CharacterData in characters:
		if c.character_id == character_id:
			return c
	return null
