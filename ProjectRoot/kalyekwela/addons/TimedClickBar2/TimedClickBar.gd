extends Control

@onready var pointer = $pointer
@onready var acceptance_region = $acceptance_region
@onready var animation_player = $AnimationPlayer
@export var pointer_is_over_target : bool

var random_number = RandomNumberGenerator.new() # create a random number generator

func _on_bar_button_button_down() -> void:
	if pointer_is_over_target:
		print("hit")
	else:
		print("miss")
	randomize_bar() # reset acceptance region length and position
	animation_player.speed_scale = random_number.randf_range(0.2, 0.7) # increase pointer speed after every button click

func randomize_bar() -> void:
	acceptance_region.scale.x = random_number.randf_range(0.3, 0.7)
	acceptance_region.position.x = random_number.randf_range(10, 360) * (1 - acceptance_region.scale.x)
