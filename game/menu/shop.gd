class_name Shop
extends Control

## Shop menu: spend currency on abilities, characters, and stat upgrades.

const ABILITIES: Array[Dictionary] = [
	{
		"id": "double_jump",
		"name": "Double Jump",
		"desc": "One extra jump while airborne.",
		"cost": 150
	},
	{
		"id": "grappling_gloves",
		"name": "Grappling Gloves",
		"desc": "60% less wall-kick on bounce.",
		"cost": 200
	},
	{
		"id": "sticky_boots",
		"name": "Sticky Boots",
		"desc": "No lateral kick — bounce straight up.",
		"cost": 300
	},
	{"id": "jetpack", "name": "Jetpack", "desc": "Hold jump for sustained thrust.", "cost": 400},
	{
		"id": "boost_recharge",
		"name": "Boost Recharge",
		"desc": "Boost refills slowly after use.",
		"cost": 250
	},
	{
		"id": "shooting",
		"name": "Shooter",
		"desc": "Left-click to fire and destroy hazards.",
		"cost": 350
	},
]
const STAT_UPGRADE_COST: int = 100
const STATS: Array[String] = ["move_speed", "jump_force", "aerodynamics"]

@onready var _currency_label: Label = $VBox/CurrencyLabel
@onready var _items_container: VBoxContainer = $VBox/ScrollContainer/ItemsContainer
@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_refresh()


func _refresh() -> void:
	_currency_label.text = "Credits: %d" % GameState.currency
	for child: Node in _items_container.get_children():
		child.queue_free()
	_add_section_header("— Abilities —")
	for ability: Dictionary in ABILITIES:
		_add_ability_row(ability)
	_add_section_header("— Characters —")
	for char_data: CharacterData in GameState.characters:
		_add_character_row(char_data)
	_add_section_header("— Stat Upgrades (%s) —" % GameState.current_character)
	var current: CharacterData = GameState.get_current_character()
	if current != null:
		for stat: String in STATS:
			_add_upgrade_row(current, stat)


func _add_section_header(text: String) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	_items_container.add_child(lbl)


func _add_ability_row(ability: Dictionary) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	var owned: bool = ability["id"] in GameState.purchased_abilities
	var status: String = "[owned]" if owned else ("%d cr" % ability["cost"])
	label.text = "%s — %s  (%s)" % [ability["name"], ability["desc"], status]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if not owned:
		var btn: Button = Button.new()
		btn.text = "Buy"
		btn.pressed.connect(_on_buy_ability.bind(ability))
		row.add_child(btn)
	_items_container.add_child(row)


func _add_character_row(char_data: CharacterData) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	var owned: bool = char_data.character_id in GameState.unlocked_characters
	var active: bool = GameState.current_character == char_data.character_id
	var status: String = (
		"[active]" if active else ("[owned]" if owned else ("%d cr" % char_data.cost))
	)
	label.text = (
		"%s — spd:%.0f jmp:%.0f aero:%.1f  (%s)"
		% [
			char_data.display_name,
			char_data.move_speed,
			char_data.jump_force,
			char_data.aerodynamics,
			status
		]
	)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if not owned and char_data.cost > 0:
		var btn: Button = Button.new()
		btn.text = "Buy"
		btn.pressed.connect(_on_buy_character.bind(char_data))
		row.add_child(btn)
	elif owned and not active:
		var btn: Button = Button.new()
		btn.text = "Select"
		btn.pressed.connect(_on_select_character.bind(char_data.character_id))
		row.add_child(btn)
	_items_container.add_child(row)


func _add_upgrade_row(char_data: CharacterData, stat: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	var tier: int = GameState.get_upgrade_tier(char_data.character_id, stat)
	var maxed: bool = tier >= char_data.max_upgrades_per_stat
	label.text = "%s  tier %d/%d" % [stat, tier, char_data.max_upgrades_per_stat]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if not maxed:
		var btn: Button = Button.new()
		btn.text = "Upgrade (%d cr)" % STAT_UPGRADE_COST
		btn.pressed.connect(_on_upgrade_stat.bind(char_data.character_id, stat))
		row.add_child(btn)
	_items_container.add_child(row)


func _on_buy_ability(ability: Dictionary) -> void:
	AudioManager.play_button()
	if GameState.purchase_ability(ability["id"], ability["cost"]):
		_refresh()


func _on_buy_character(char_data: CharacterData) -> void:
	AudioManager.play_button()
	if GameState.unlock_character(char_data.character_id, char_data.cost):
		_refresh()


func _on_select_character(character_id: String) -> void:
	AudioManager.play_button()
	GameState.current_character = character_id
	_refresh()


func _on_upgrade_stat(character_id: String, stat: String) -> void:
	AudioManager.play_button()
	if GameState.upgrade_stat(character_id, stat, STAT_UPGRADE_COST):
		_refresh()


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
