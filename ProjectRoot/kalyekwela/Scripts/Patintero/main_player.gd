extends Player

@onready var player_animation = $AnimatedSprite2D
@onready var player_name_label = $player_name
@onready var timer = $Timer
@onready var game_scene : BaseGame = get_parent()

var time = 0
var speed = 50
@export var player_speed = 200 # Default speed of player
# Indicate if player is still alive


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name_label.text = "Player"
	if game_scene is not BaseGame:
		print("game scene error")

# Called every frame. 'delta' is the elapsed time since the previous frame.
	move_and_slide()
func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		update_animation(direction)

	velocity = direction * speed 
	move_and_slide()

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		player_animation.play("WalkSide")
		player_animation.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		player_animation.play("WalkFront")
	else:
		player_animation.play("WalkBack")


func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"): 	# detect if player collided with enemy bot
		emit_signal("touched_enemy")
	if area.is_in_group("score_line"): # add coin if player passed a vertical line
		game_scene.add_points(1)
	if area.is_in_group("rock"):
		timer.start()
		player_animation.modulate = Color(1, 0, 0, 1) # add a red tint to player sprite
		player_speed -= 30 * game_scene.level 


func _on_timer_timeout() -> void:
	timer.stop()
	player_animation.modulate = Color(1, 1, 1, 1) # add a red tint to player sprite
	player_speed += 30 * game_scene.level 
