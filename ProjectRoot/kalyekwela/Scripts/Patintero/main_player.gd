extends Player

@onready var player_animation = $AnimatedSprite2D
@onready var player_name_label = $player_name
@onready var timer = $Timer
@onready var game_scene : BaseGame = get_parent()
@onready var oof_sfx = $oof_sfx
var time = 0
var action_label_time : float = 2

var base_speed : float = 110 # Default player running speed
@export var player_speed : float


var slowed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name_label.text = "Player"
	if game_scene is not BaseGame:
		print("game scene error")
	update_speed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
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

	velocity = direction * player_speed
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

func update_speed() -> void:
	player_speed = base_speed + (game_scene.level * 0.5)

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy"): 	# detect if player collided with enemy bot
		emit_signal("touched_enemy")
	if area.is_in_group("score_line"): # add coin if player passed a vertical line
		game_scene.add_points(1)
	if area.is_in_group("rock"):
		oof_sfx.play()
		slow_down()

func slow_down() -> void:
	if not slowed:
		print("I hate rocks")
		slowed = true
		player_animation.modulate = Color(1, 0, 0, 1) # add a red tint to player sprite
		player_speed /= 3
		await get_tree().create_timer(0.5).timeout
		player_animation.modulate = Color(1, 1, 1, 1) # add a red tint to player sprite
		player_speed *= 3
		slowed = false
	
