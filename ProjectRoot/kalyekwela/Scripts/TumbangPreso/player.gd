extends Player

@onready var player_animation = $AnimatedSprite2D
@onready var player_name_label = $player_name
@onready var timer = $Timer

var time = 0
var speed = 200
@export var player_speed = 200 # Default speed of player
# Indicate if player is still alive

signal touched_sandal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

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
	if area.is_in_group("safe_area"):
		emit_signal("in_safe_area")
		
