extends Node

## Global game state: score, lives, unlocks, current level, economy.

var score: int = 0
var lives: int = 3
var current_level: int = 0
var unlocked_levels: Array[int] = [0]
var levels: Array[LevelData] = []

var currency: int = 0
var purchased_abilities: Array[String] = []
var current_character: String = "penguin"
var unlocked_characters: Array[String] = ["penguin"]


func _ready() -> void:
	levels = LevelLoader.load_all()


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
