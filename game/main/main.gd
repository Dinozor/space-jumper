class_name Main
extends Node

## Bootstrap scene: immediately loads the main menu.


func _ready() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://game/menu/main_menu.tscn")
