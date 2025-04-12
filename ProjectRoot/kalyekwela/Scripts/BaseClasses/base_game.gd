class_name BaseGame
extends Node2D

var coins = 0
var exp = 0


# End event sequence
func end_game() -> void:
	GlobalData.add_rewards(coins, exp)
	print("Coins: " + str(coins) + "Exp: " + str(exp))
	# Wait a few seconds before quitting 
	await get_tree().create_timer(3).timeout
	print("Game ended!")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")
