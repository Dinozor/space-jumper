class_name Shop
extends Control

## Shop: two tabs — Upgrades (ability grid) and Characters (cards + stat upgrades).
## Abilities are loaded from GameState.abilities — no hardcoded list here.

const STATS: Array[String] = ["move_speed", "jump_force", "aerodynamics"]
const STAT_UPGRADE_COST: int = 100

@onready var _currency_label: Label = $VBox/CurrencyLabel
@onready var _grid: GridContainer = $VBox/Tabs/Upgrades/Grid
@onready var _char_list: VBoxContainer = $VBox/Tabs/Characters/CharList
@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_refresh()


func _refresh() -> void:
	_currency_label.text = "Credits: %d" % GameState.currency
	_build_upgrades_grid()
	_build_characters_list()


func _build_upgrades_grid() -> void:
	for child: Node in _grid.get_children():
		child.queue_free()
	for ab: AbilityData in GameState.abilities:
		_grid.add_child(_make_ability_card(ab))


func _make_ability_card(ab: AbilityData) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var vbox: VBoxContainer = VBoxContainer.new()
	card.add_child(vbox)
	var title: Label = Label.new()
	title.text = ab.display_name
	vbox.add_child(title)
	var desc: Label = Label.new()
	desc.text = ab.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	var owned: bool = ab.ability_id in GameState.purchased_abilities
	if owned:
		var lbl: Label = Label.new()
		lbl.text = "[owned]"
		vbox.add_child(lbl)
	else:
		var btn: Button = Button.new()
		btn.text = "Buy  %d cr" % ab.cost
		btn.pressed.connect(_on_buy_ability.bind(ab))
		vbox.add_child(btn)
	return card


func _build_characters_list() -> void:
	for child: Node in _char_list.get_children():
		child.queue_free()
	for char_data: CharacterData in GameState.characters:
		_char_list.add_child(_make_character_card(char_data))


func _make_character_card(char_data: CharacterData) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var vbox: VBoxContainer = VBoxContainer.new()
	card.add_child(vbox)
	_add_char_header(vbox, char_data)
	_add_char_stats(vbox, char_data)
	return card


func _add_char_header(vbox: VBoxContainer, char_data: CharacterData) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var lbl: Label = Label.new()
	var owned: bool = char_data.character_id in GameState.unlocked_characters
	var active: bool = GameState.current_character == char_data.character_id
	var status: String = (
		"[active]" if active else ("[owned]" if owned else "%d cr" % char_data.cost)
	)
	lbl.text = "%s  (%s)" % [char_data.display_name, status]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
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
	vbox.add_child(row)


func _add_char_stats(vbox: VBoxContainer, char_data: CharacterData) -> void:
	var owned: bool = char_data.character_id in GameState.unlocked_characters
	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	for stat: String in STATS:
		var tier: int = GameState.get_upgrade_tier(char_data.character_id, stat)
		var maxed: bool = tier >= char_data.max_upgrades_per_stat
		var lbl: Label = Label.new()
		lbl.text = "%s t%d" % [stat.left(4), tier]
		grid.add_child(lbl)
		var btn: Button = Button.new()
		btn.text = "+  %d cr" % STAT_UPGRADE_COST
		btn.disabled = maxed or not owned
		btn.pressed.connect(_on_upgrade_stat.bind(char_data.character_id, stat))
		grid.add_child(btn)
	vbox.add_child(grid)


func _on_buy_ability(ab: AbilityData) -> void:
	AudioManager.play_button()
	if GameState.purchase_ability(ab.ability_id, ab.cost):
		_refresh()


func _on_buy_character(char_data: CharacterData) -> void:
	AudioManager.play_button()
	if GameState.unlock_character(char_data.character_id, char_data.cost):
		_refresh()


func _on_select_character(character_id: String) -> void:
	AudioManager.play_button()
	GameState.current_character = character_id
	SaveManager.save_progression()
	_refresh()


func _on_upgrade_stat(character_id: String, stat: String) -> void:
	AudioManager.play_button()
	if GameState.upgrade_stat(character_id, stat, STAT_UPGRADE_COST):
		_refresh()


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
