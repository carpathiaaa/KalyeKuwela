extends Node2D

class_name base_game

var coins = 0
var exp = 0



func _process(delta: float) -> void:
	pass
#	self.game_over.connect(end_game)

func end_game() -> void:
	GlobalData.add_rewards(coins, exp)
	# Wait a few seconds before quitting
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")
