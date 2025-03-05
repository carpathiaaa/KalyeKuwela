extends CanvasLayer

@onready var main_script = $"../"
@onready var points_label = $Control/points_label
@onready var level_label = $Control/level_label
@onready var coins_label = $Control/coins_label
@onready var coin_image = $Control/coin_image
@onready var game_over_label = $Control/game_over_label
@onready var game_over_bg = $Control/game_over_bg
@onready var return_button = $Control/return_button
# Called when the node enters the scene tree for the first time.

func show_points(points : int) -> void:
	points_label.text = "Points: " + str(points)
	
func hide_interface() -> void:
	points_label.visible = false
	level_label.visible = false
	coins_label.visible = false
	coin_image.visible = false
	game_over_label.visible = true
	game_over_bg.visible = true
	return_button.visible = true

func show_level(level : int) -> void:
	level_label.text = "Level: " + str(level)
	
func show_coins(coins: int) -> void:
	coins_label.text = str(coins)


func _on_button_pressed() -> void:
	main_script.return_to_main_menu()
