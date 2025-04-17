class_name BaseGame
extends Node2D

var level : int = 1
var coins : int = 0
var exp : int = 0

@onready var score_summary = preload("res://Scenes/BaseScenes/UI/score_summary.tscn")
@onready var ui_layer = CanvasLayer.new()

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

func end_sequence() -> void:
	print("starting end sequence")
	await get_tree().create_timer(1).timeout
	if !game_ended:
		end_game()



func end_game() -> void:
	game_ended = true
	GlobalData.add_rewards(coins, exp)
	Engine.time_scale = 1
	show_summary()
	get_tree().change_scene_to_packed(score_summary)
