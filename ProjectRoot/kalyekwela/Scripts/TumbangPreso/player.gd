extends Player

@onready var player_animation = $AnimatedSprite2D
@onready var player_name_label = $player_name
@onready var timer = $Timer
@onready var game_scene : BaseGame = get_parent().get_parent()

var time = 0
@export var player_speed = 200 # Default speed of player
# Indicate if player is still alive

signal touched_sandal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name_label.text = "Player"
	if game_scene is not BaseGame:
		print("game scene error")

# Called every frame. 'delta' is the elapsed time since the previous frame.
	move_and_slide()
func _process(delta):
	# determine player movement based on player_speed and direction
	velocity = player_speed * Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	if area.is_in_group("enemy"): 	# detect if player collided with enemy bot
		emit_signal("touched_enemy")
	if area.is_in_group("safe_area"):
		emit_signal("in_safe_area")



func _on_timer_timeout() -> void:
	timer.stop()
	player_animation.modulate = Color(1, 1, 1, 1) # add a red tint to player sprite
	player_speed += 30 * game_scene._level 
