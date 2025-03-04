extends Node2D

@onready var patintero_interface = $"../Patintero/patintero_labels"
@onready var main_player = $main_player/body
@onready var touch_controls = $Control/touch_controls
@onready var coin_sfx = $sound_effects/coin_sfx
var _coins = 0
var _points = 0
var _level = 0

func player_death() -> void:
	patintero_interface.hide_interface()
	touch_controls.visible = false
	main_player.player_speed = 0

func add_points(points_gained : int) -> void:
	_points += points_gained
	patintero_interface.show_points(_points)

func add_coins(coins_gained : int) -> void:
	_coins += coins_gained
	patintero_interface.show_coins(_coins)
	coin_sfx.play()

func add_level() -> void:
	_level += 1
	patintero_interface.show_level(_level)
	
