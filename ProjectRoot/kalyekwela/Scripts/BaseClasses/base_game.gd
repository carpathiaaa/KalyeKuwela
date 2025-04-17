class_name BaseGame
extends Node2D

var level : int = 1
var coins : int = 0
var exp : int = 0

# End event sequence
var game_ended : bool = false

func add_coins(new_coins: int) -> void:
	print("Added " + str(new_coins) + " coins")
	coins += new_coins

func add_exp(new_exp: int) -> void:
	print("Added " + str(new_exp) + " new exp")
	exp += new_exp

func end_sequence() -> void:
	print("starting end sequence")
	await get_tree().create_timer(3).timeout
	if !game_ended: # Prevent end_game from being called multiple times
		end_game()

func end_game() -> void:
	game_ended = true
	GlobalData.add_rewards(coins, exp)
	print("Coins: " + str(coins) + " Exp: " + str(exp))
	# Wait a few seconds before quitting 
	print("Game ended!")
	Engine.time_scale = 1 # Ensure engine processes are not paused after quitting.
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")
