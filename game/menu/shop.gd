class_name Shop
extends Control

## Shop menu: spend currency on abilities and character unlocks.

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
	for ability: Dictionary in ABILITIES:
		_add_item_row(ability)


func _add_item_row(ability: Dictionary) -> void:
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
		btn.pressed.connect(_on_buy_pressed.bind(ability))
		row.add_child(btn)
	_items_container.add_child(row)


func _on_buy_pressed(ability: Dictionary) -> void:
	AudioManager.play_button()
	if GameState.purchase_ability(ability["id"], ability["cost"]):
		_refresh()


func _on_back_pressed() -> void:
	AudioManager.play_button()
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
