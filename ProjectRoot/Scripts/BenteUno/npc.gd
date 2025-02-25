extends CharacterBody2D

@export var speed: float = 100
var is_chaser: bool = false
var target_direction: Vector2
var target_runner: CharacterBody2D = null  # Chasers will chase this
var nearby_chaser: CharacterBody2D = null  # Runners will flee from this
var chase_speed: float = 20  # Speed boost when chasing
var flee_speed: float = 160  # Speed boost when fleeing

@onready var timer = $Timer
@onready var status_label = $StatusLabel
@onready var detection_area = $DetectionArea  # Detect runners if chaser
@onready var flee_area = $FleeArea  # Detect chasers if runner
@onready var animated_sprite = $AnimatedSprite2D  # Reference to AnimatedSprite2D

func _ready():
	add_to_group("npc")
	randomize()
	pick_new_direction()
	timer.wait_time = randf_range(1.5, 3)
	timer.start()
	update_status()
	
	# Connect detection signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	flee_area.body_entered.connect(_on_flee_area_body_entered)
	flee_area.body_exited.connect(_on_flee_area_body_exited)

func _physics_process(delta):
	if is_chaser and target_runner and not target_runner.is_chaser:
		# Chase the runner
		target_direction = (target_runner.global_position - global_position).normalized()
		velocity = target_direction * chase_speed
	elif not is_chaser and nearby_chaser:
		# Flee from chaser
		target_direction = (global_position - nearby_chaser.global_position).normalized()
		velocity = target_direction * flee_speed
	else:
		# Default wandering movement
		velocity = target_direction * speed

	update_animation(target_direction)

	# Check for collisions before moving
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider:
			_on_body_entered(collider)  # Handle collision with another entity
		handle_collision()  # Change direction on collision

	move_and_slide()

func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("IdleSide")
		animated_sprite.flip_h = direction.x < 0  # Flip sprite if moving left
	elif direction.y > 0:
		animated_sprite.play("WalkFront")
	else:
		animated_sprite.play("IdleBack")

func pick_new_direction():
	target_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func handle_collision():
	# Change direction slightly instead of stopping
	target_direction = target_direction.rotated(randf_range(PI / 4, PI / 2)).normalized()
	pick_new_direction()

func _on_Timer_timeout():
	if not is_chaser or target_runner == null:
		pick_new_direction()  # Keep moving randomly only if not chasing
	timer.wait_time = randf_range(1.5, 3)
	timer.start()

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_chaser and not is_chaser:
		print(body.name, " tagged ", name, " - Now a chaser!")
		become_chaser()
	elif body is CharacterBody2D and is_chaser and not body.is_chaser:
		print(name, " tagged ", body.name, " - They are now a chaser!")
		body.become_chaser()
		target_runner = null  # Stop chasing after tagging

func _on_detection_area_body_entered(body):
	if body is CharacterBody2D and not body.is_chaser and is_chaser:
		target_runner = body  # Start chasing the runner
		print(name, " detected ", body.name, " and is now chasing!")

func _on_detection_area_body_exited(body):
	if body == target_runner:
		target_runner = null  # Stop chasing if runner leaves radius
		print(name, " lost sight of ", body.name)

func _on_flee_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser and not is_chaser:
		nearby_chaser = body  # Start fleeing
		print(name, " noticed ", body.name, " and is fleeing!")

func _on_flee_area_body_exited(body):
	if body == nearby_chaser:
		nearby_chaser = null  # Stop fleeing if chaser leaves radius
		print(name, " is safe now.")

func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 130  # Slight speed boost
		target_runner = null  # Stop chasing when turned into a chaser
		nearby_chaser = null  # Stop fleeing when becoming a chaser
		pick_new_direction()  # Resume random movement
		update_status()
		print(name, " has become a CHASER!")

func update_status():
	if is_chaser:
		modulate = Color.RED
		status_label.text = "Chaser"
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		status_label.text = "Runner"
		status_label.add_theme_color_override("font_color", Color.BLUE)
