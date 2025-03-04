extends CharacterBody2D

@onready var player_animation = $AnimatedSprite2D
@onready var player_name = $player_name
@onready var timer = $Timer
@onready var main_patintero = $"../../"
var time = 0
@export var player_speed = 200 # Default speed of player
# Indicate if player is still alive

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name.text = "Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# determine player movement based on player_speed and direction
	velocity = player_speed * (Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")).normalized() # normalize for uniform speed
	if (velocity.y > 0):
		player_animation.play("down_animation")
	elif (velocity.y < 0):
		player_animation.play("up_animation") 
	if (velocity.x > 0):
		player_animation.scale.x = 1
		player_animation.play("side_animation")
	elif (velocity.x < 0):
		player_animation.scale.x = -1
		player_animation.play("side_animation")
	# enable diagonal movement
	move_and_slide()


func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_bot"): 	# detect if player collided with enemy bot
		main_patintero.player_death()
	
	if area.is_in_group("score_line"): # add coin if player passed a vertical line
		main_patintero.add_points(1)
	
	if area.is_in_group("rock"):
		timer.start()
		player_animation.modulate = Color(1, 0, 0, 1) # add a red tint to player sprite
		player_speed -= 30 * main_patintero._level 


func _on_timer_timeout() -> void:
	timer.stop()
	player_animation.modulate = Color(1, 1, 1, 1) # add a red tint to player sprite
	player_speed += 30 * main_patintero._level 
