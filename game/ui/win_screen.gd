class_name WinScreen
extends CanvasLayer

## Win screen: shows coins earned, offers navigation to next level, shop, replay, or menu.

signal play_again_pressed
signal next_level_pressed
signal shop_pressed
signal menu_pressed

@onready var _result_label: Label = $Panel/ResultLabel
@onready var _coins_label: Label = $Panel/CoinsLabel
@onready var _play_again_button: Button = $Panel/PlayAgainButton
@onready var _next_level_button: Button = $Panel/NextLevelButton
@onready var _next_level_hint: Label = $Panel/NextLevelHint
@onready var _shop_button: Button = $Panel/ShopButton
@onready var _menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_next_level_button.pressed.connect(_on_next_level_pressed)
	_shop_button.pressed.connect(_on_shop_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_play_again_pressed() -> void:
	AudioManager.play_button()
	play_again_pressed.emit()


func _on_next_level_pressed() -> void:
	AudioManager.play_button()
	next_level_pressed.emit()


func _on_shop_pressed() -> void:
	AudioManager.play_button()
	shop_pressed.emit()


func _on_menu_pressed() -> void:
	AudioManager.play_button()
	menu_pressed.emit()


## Shows coins earned and total, gates Next Level button, then reveals the win screen.
func show_result(earned: int, total: int) -> void:
	_result_label.text = "You reached the station!"
	_coins_label.text = "+%d coins  ·  Total: %d" % [earned, total]
	var next_id: int = GameState.current_level + 1
	var has_next: bool = next_id in GameState.unlocked_levels
	_next_level_button.disabled = not has_next
	_next_level_hint.visible = not has_next
	show()
