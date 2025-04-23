extends CharacterBody2D

@export var speed: float = 100
var is_chaser: bool = false
var target_direction: Vector2
var target_runner: CharacterBody2D = null  # Chasers will chase this
var nearby_chaser: CharacterBody2D = null  # Runners will flee from this
var chase_speed: float = 80  # Further reduced chaser speed
var flee_speed: float = 200  # Increased flee speed to make runners harder to catch

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
	if is_chaser:
		update_chaser_behavior()
	else:
		update_runner_behavior()

	# Check for collisions before moving
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider:
			_on_body_entered(collider)  # Handle collision with another entity
		handle_collision()  # Change direction on collision

	move_and_slide()
	update_animation(target_direction)

# --- CHASER BEHAVIOR ---
func update_chaser_behavior():
	if not target_runner or target_runner.is_chaser:
		target_runner = find_closest_runner()
	
	if target_runner:
		target_direction = (target_runner.global_position - global_position).normalized()
		velocity = target_direction * chase_speed
	else:
		# No runner detected, move randomly
		velocity = target_direction * speed

# --- RUNNER BEHAVIOR ---
func update_runner_behavior():
	if nearby_chaser:
		var flee_vector = global_position - nearby_chaser.global_position
		
		# Predictive fleeing: anticipate chaser's future position
		var predicted_chaser_pos = nearby_chaser.global_position + nearby_chaser.velocity * 0.3
		var predicted_flee_vector = global_position - predicted_chaser_pos
		
		# If the predicted position is closer, prioritize it
		if predicted_flee_vector.length() < flee_vector.length():
			flee_vector = predicted_flee_vector

		# Check for walls in the flee direction
		if is_path_blocked(flee_vector.normalized()):
			flee_vector = find_alternate_escape_route(flee_vector)
		
		# Apply smart dodging (slight random angle)
		flee_vector = add_random_dodge(flee_vector)

		# Dynamic speed boost when very close to a chaser
		var distance = global_position.distance_to(nearby_chaser.global_position)
		var dynamic_speed = flee_speed + (200 - distance) * 0.5  
		velocity = flee_vector.normalized() * clamp(dynamic_speed, flee_speed, flee_speed + 50)
	else:
		# Default wandering movement
		velocity = target_direction * speed

func find_closest_runner():
	var closest_runner = null
	var min_distance = INF

	for body in detection_area.get_overlapping_bodies():
		if body is CharacterBody2D and not body.is_chaser:
			var distance = global_position.distance_to(body.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_runner = body

	return closest_runner

func add_random_dodge(direction: Vector2) -> Vector2:
	# Dodge intelligently instead of randomly
	var dodge_angle = randf_range(-PI / 8, PI / 8)
	return direction.rotated(dodge_angle).normalized()

func is_path_blocked(direction: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + direction * 30, 1)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func find_alternate_escape_route(original_flee_vector: Vector2) -> Vector2:
	var left_flee = original_flee_vector.rotated(PI / 4)
	var right_flee = original_flee_vector.rotated(-PI / 4)

	if not is_path_blocked(left_flee):
		return left_flee.normalized()
	elif not is_path_blocked(right_flee):
		return right_flee.normalized()
	else:
		return -original_flee_vector.normalized()  # As a last resort, move backwards

func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("WalkSide")
		animated_sprite.flip_h = direction.x < 0  # Flip sprite if moving left
	elif direction.y > 0:
		animated_sprite.play("WalkFront")
	else:
		animated_sprite.play("WalkBack")

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
		# Check if this is the player before converting to chaser
		if body.has_method("is_player") and body.is_player():
			# Let the player handle its own health
			print(name, " tagged player!")
			
		else:
			# This is another NPC, so convert directly
			print(name, " tagged ", body.name, " - They are now a chaser!")
			body.become_chaser()
			
		target_runner = null  # Stop chasing after tagging

func _on_detection_area_body_entered(body):
	if body is CharacterBody2D and not body.is_chaser and is_chaser:
		target_runner = find_closest_runner()  # Find the nearest runner
		#print(name, " detected ", body.name, " and is now chasing!")

func _on_detection_area_body_exited(body):
	if body == target_runner:
		target_runner = null  # Stop chasing if runner leaves radius
		#print(name, " lost sight of ", body.name)

func _on_flee_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser and not is_chaser:
		nearby_chaser = body  # Start fleeing
		#print(name, " noticed ", body.name, " and is fleeing!")

func _on_flee_area_body_exited(body):
	if body == nearby_chaser:
		nearby_chaser = null  # Stop fleeing if chaser leaves radius
		#print(name, " is safe now.")

func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 100  # Slight speed boost
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
