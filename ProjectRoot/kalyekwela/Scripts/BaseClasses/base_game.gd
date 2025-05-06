class_name BaseGame
extends Node2D

var level : int = 1
var coins : int = 0
var exp : int = 0

@onready var score_summary = preload("res://Scenes/BaseScenes/UI/score_summary.tscn")
@onready var ui_layer = CanvasLayer.new()

var current_game : String = "res://Scenes/MainMenu/menu.tscn" # default location string
var game_ended : bool = false

func _ready():
	add_child(ui_layer)
	ui_layer.layer = 100

func add_coins(new_coins: int) -> void:
	print("Added " + str(new_coins) + " coins")
	coins += new_coins

func add_exp(new_exp: int) -> void:
	print("Added " + str(new_exp) + " new exp")
	exp += new_exp

func show_summary() -> void:
	var score_summary_instance = score_summary.instantiate()
	score_summary_instance.added_coins = coins
	score_summary_instance.added_exp = exp
	ui_layer.add_child(score_summary_instance)

# Add this to your scene change logic (before changing scenes)
func disconnect_input_signals():
	print("Releasing input signals")
	# Release all movement actions
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")

func end_sequence() -> void:
	print("starting end sequence")
	if !game_ended:
		end_game()

func end_game() -> void:
	game_ended = true
	disconnect_input_signals()
	coins = 0 if coins < 0 else coins
	exp = 0 if exp < 0 else exp
	GlobalData.add_rewards(coins, exp)
	GlobalData.previous_game = current_game
	Engine.time_scale = 1
	show_summary()
	CompactTransition.load_scene("res://Scenes/BaseScenes/UI/score_summary.tscn")
	#get_tree().change_scene_to_packed(score_summary)
