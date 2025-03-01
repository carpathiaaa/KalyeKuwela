extends CharacterBody2D

@export var speed: float = 200
var is_chaser: bool = false

@onready var status_label = $StatusLabel
@onready var tag_area = $TagArea  # Reference to Area2D
@onready var animated_sprite = $AnimatedSprite2D  # Reference to AnimatedSprite2D

func _ready():
	status_label.show()
	status_label.position.y = -20
	update_status()

	# Ensure the tag_area exists and properly connects the signal
	if tag_area:
		tag_area.body_entered.connect(_on_tag_area_body_entered)
	else:
		print("Error: TagArea not found in Player!")

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

func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("IdleSide")
		animated_sprite.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		animated_sprite.play("WalkFront")
	else:
		animated_sprite.play("WalkBack")

func _on_tag_area_body_entered(body):
	# Ensure we're tagging an NPC that is a runner
	if body is CharacterBody2D and not body.is_chaser and is_chaser:
		print(name, " tagged ", body.name, " - They are now a chaser!")
		body.become_chaser()

func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 220  # Slight boost for chasers
		update_status()
		print(name, " has become a CHASER!")

func update_status():
	status_label.show()
	if is_chaser:
		modulate = Color.RED
		status_label.text = "Chaser"
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		modulate = Color.WHITE
		status_label.text = "Runner"
		status_label.add_theme_color_override("font_color", Color.BLUE)
