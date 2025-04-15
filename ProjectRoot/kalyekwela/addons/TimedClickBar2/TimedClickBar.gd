extends Control

@onready var pointer = $pointer
@onready var acceptance_region = $acceptance_region
@onready var pointer_animation = $pointer_animation
@onready var button_timer = $bar_button/button_timer
@onready var button_sprite = $bar_button/SmallSquareButtons
@onready var button_icon = $bar_button/button_icon
@onready var sandal_sprite = $"../sandal/SandalByAdityasusant938"

@export var pointer_is_over_target : bool

var random_number = RandomNumberGenerator.new() # create a random number generator

var new_points = 0
var new_coins = 5
signal gain_rewards(new_points, new_coins)

func _on_bar_button_button_down() -> void:
	button_timer.start() # start timer for button sprite animation
	button_sprite.frame = 1 # change buttons sprite to pressed state
	if pointer_is_over_target:
		print("hit")
		new_points = 150
		new_coins = 5
		emit_signal("gain_rewards")
		button_icon.modulate = Color(0.7, 1.8, 0.7) # Greenish tint if hit
	else:
		print("miss")
		new_points = -100
		new_coins = 0
		emit_signal("gain_rewards")
		button_icon.modulate = Color(1.8, 0.7, 0.7) # Reddish tint if miss
	randomize_bar() # reset acceptance region length and position
	pointer_animation.speed_scale = random_number.randf_range(0.2, 0.7) # increase pointer speed after every button click

func randomize_bar() -> void:
	acceptance_region.scale.x = random_number.randf_range(0.3, 0.7)
	acceptance_region.position.x = random_number.randf_range(10, 360) * (1 - acceptance_region.scale.x)

# return button sprite to normal state
func _on_button_timer_timeout() -> void:
	button_sprite.frame = 0
