extends Control

@onready var pointer = $pointer
@onready var acceptance_region = $acceptance_region
@onready var pointer_animation = $pointer_animation
@onready var button = $bar_button
@onready var button_timer = $bar_button/button_timer
@onready var button_sprite = $bar_button/SmallSquareButtons
@onready var button_icon = $bar_button/button_icon
@onready var sandal_sprite = $"../sandal/SandalByAdityasusant938"
@onready var guide_label = $Container/GuideLabel
@onready var green_outline = $Container/GreenOutline
@onready var hit_sfx = $hit_sfx
@onready var miss_sfx = $miss_sfx

@export var pointer_is_over_target : bool = false
signal change_pointer_state(pointer_is_over_target)

var random_number = RandomNumberGenerator.new() # create a random number generator

var clickable : bool = true

func _ready() -> void:
	button_timer.one_shot = true  # Ensure timer stops after one trigger
	button_timer.wait_time = 0.15

func _on_bar_button_button_down() -> void:
	button_timer.start()
	button_sprite.frame = 1 # change buttons sprite to pressed state
	if pointer_is_over_target:
		print("hit")
		hit_sfx.play()
		get_parent().update_phase_rewards(1, 4)
		button_icon.modulate = Color(0.7, 1.8, 0.7) # Greenish tint if hit
	else:
		print("miss")
		miss_sfx.play()
		get_parent().update_phase_rewards(0, -2)
		button_icon.modulate = Color(1.8, 0.7, 0.7) # Reddish tint if miss
	randomize_bar() # reset acceptance region length and position
	pointer_animation.speed_scale = random_number.randf_range(0.4, 0.65) # increase pointer speed after every button click

func change_state(new_state: bool) -> void:
	pointer_is_over_target = new_state
	if new_state:
		guide_label.show()
		green_outline.show()
	else:
		guide_label.hide()
		green_outline.hide()
	emit_signal("change_pointer_state", pointer_is_over_target)

func randomize_bar() -> void:
	acceptance_region.scale.x = random_number.randf_range(0.35, 0.6) * (1 + (0.2 * pointer_animation.speed_scale))
	acceptance_region.position.x = random_number.randf_range(10, 360) * (1 - acceptance_region.scale.x)

# return button sprite to normal state
func _on_button_timer_timeout() -> void:
	button_sprite.frame = 0
	button_icon.modulate = Color(1.0, 1.0, 1.0)
