extends CanvasLayer

@onready var main_script = $"../"
@onready var touch_controls = $"Virtual Joystick"
@onready var points_label = $Control/points_label
@onready var level_label = $Control/level_label
@onready var coins_label = $Control/coins_label
@onready var coin_image = $Control/coin_image
@onready var game_over_label = $Control/game_over_label
@onready var black_background = $Control/black_background
@onready var return_button = $Control/return_button # returns to main menu
@onready var pause_button = $Control/PauseButton
@onready var pause_menu = $Control/PauseMenu

var paused : bool = false

func show_points(points : int) -> void:
	points_label.text = "Points: " + str(points)

func show_level(level : int) -> void:
	level_label.text = "Level: " + str(level)

func show_coins(coins: int) -> void:
	coins_label.text = str(coins)

func _on_pause_button_pressed() -> void:
	paused = true
	pauseMenu()

func _ready():
	if Input.is_action_just_pressed('pause'):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.show()
		touch_controls.visible = false
		black_background.visible = true
		Engine.time_scale = 0
	else:
		pause_menu.hide()
		touch_controls.visible = true
		black_background.visible = false
		Engine.time_scale = 1

func _on_resume_button_pressed() -> void:
	paused = false
	pauseMenu()

func _on_quit_button_pressed() -> void:
	main_script.return_to_main_menu()

func hide_interface() -> void:
	touch_controls.visible = false
	points_label.visible = false
	level_label.visible = false
	coins_label.visible = false
	coin_image.visible = false
	pause_button.visible = false
	game_over_label.visible = true
	black_background.visible = true
	return_button.visible = true

func _on_button_pressed() -> void:
	main_script.return_to_main_menu()
