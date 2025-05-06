extends Player

@onready var player_animation = $AnimatedSprite2D
@onready var player_name_label = $player_name
@onready var timer = $Timer
@onready var ouch_sfx = $ouch_effect
@onready var laugh_sfx = $laugh_effect
var time = 0
@export var speed : float = 300.0 # Default speed of player
var slowed : bool = false

var can_move: bool = false

signal touched_sandal
signal in_safe_area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_move = false
	await get_tree().create_timer(0.01).timeout
	can_move = true

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
		laugh_sfx.play()
		emit_signal("touched_enemy")
	if area.is_in_group("safe_area"):
		emit_signal("in_safe_area")
	if area.is_in_group("rock"):
		ouch_sfx.play()
		slow_down()

func slow_down() -> void:
	if not slowed:
		print("I hate rocks")
		slowed = true
		player_animation.modulate = Color(1, 0, 0, 1) # add a red tint to player sprite
		speed /= 1.5
		await get_tree().create_timer(0.5).timeout
		player_animation.modulate = Color(1, 1, 1, 1) # add a red tint to player sprite
		speed *= 1.5
		slowed = false
		
