extends CanvasLayer

@onready var points_label = $points_label
@onready var level_label = $level_label
@onready var coins_label = $coins_label
@onready var coin_image = $coin_image
@onready var game_over_label = $game_over_label
@onready var game_over_bg = $game_over_bg
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

func show_level(level : int) -> void:
	level_label.text = "Level: " + str(level)
	
func show_coins(coins: int) -> void:
	coins_label.text = str(coins)
