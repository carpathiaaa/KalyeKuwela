class_name BaseGame
extends Node2D

var level : int = 1
var coins : int = 0
var exp : int = 0

# End event sequence

func add_coins(new_coins: int) -> void:
	print("Added " + str(new_coins) + " coins")
	coins += new_coins

func add_exp(new_exp: int) -> void:
	print("Added " + str(new_exp) + " new exp")
	exp += new_exp

func end_sequence() -> void:
	print("starting end sequence")
	await get_tree().create_timer(3).timeout
	end_game()

func end_game() -> void:
	GlobalData.add_rewards(coins, exp)
	print("Coins: " + str(coins) + "Exp: " + str(exp))
	# Wait a few seconds before quitting 
	print("Game ended!")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")
