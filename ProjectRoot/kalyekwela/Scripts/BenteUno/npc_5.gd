extends CharacterBody2D

@export var speed: float = 100
var is_chaser: bool = false
var target_direction: Vector2
var target_runner: CharacterBody2D = null  # Chasers will chase this
var nearby_chaser: CharacterBody2D = null  # Runners will flee from this
var chase_speed: float = 80 
var flee_speed: float = 140 

var path: Array = []
var path_index: int = 0
var pathfinding_enabled: bool = true
var pathfinding_timer: float = 0
var pathfinding_update_time: float = 0.5  # Update path every 0.5 seconds
var flee_pathfinding_update_time: float = 0.3  # Update flee path more frequently

# Safe points for runners to flee toward
var safe_points: Array = []
var current_safe_point: Vector2 = Vector2.ZERO

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
		update_chaser_behavior(delta)
	else:
		update_runner_behavior(delta)

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
func update_chaser_behavior(delta):
	if not target_runner or target_runner.is_chaser:
		target_runner = find_closest_runner()
		clear_path()  # Clear path when changing targets
	
	if target_runner:
		# Update pathfinding periodically
		pathfinding_timer += delta
		if pathfinding_timer >= pathfinding_update_time:
			pathfinding_timer = 0
			calculate_path_to_target(target_runner.global_position)
		
		if pathfinding_enabled and path.size() > 0:
			follow_path()
		else:
			# Fallback to direct movement if pathfinding fails
			target_direction = (target_runner.global_position - global_position).normalized()
			velocity = target_direction * chase_speed
	else:
		# No runner detected, move randomly
		velocity = target_direction * speed

# --- RUNNER BEHAVIOR ---
func update_runner_behavior(delta):
	if nearby_chaser:
		# Update pathfinding more frequently when fleeing
		pathfinding_timer += delta
		if pathfinding_timer >= flee_pathfinding_update_time:
			pathfinding_timer = 0
			calculate_flee_path()
		
		if pathfinding_enabled and path.size() > 0:
			follow_flee_path()
		else:
			# Fallback to direct fleeing if pathfinding fails
			direct_flee_behavior()
	else:
		# No chaser nearby, move randomly
		velocity = target_direction * speed

# Calculate a path to a safe point away from chaser
func calculate_flee_path():
	if nearby_chaser:
		var flee_target = determine_flee_target()
		
		var map_rid = NavigationServer2D.get_maps()[0]  # Get the first navigation map
		if map_rid.is_valid():
			# Calculate path to safe point
			path = NavigationServer2D.map_get_path(map_rid, global_position, flee_target, true)
			path_index = 0
		else:
			# Fallback if navigation is not available
			path = [global_position, flee_target]
			path_index = 0

# Determine where to flee to
func determine_flee_target() -> Vector2:
	var flee_vector = global_position - nearby_chaser.global_position
	
	# Get the flee direction and calculate a point some distance away
	var flee_direction = flee_vector.normalized()
	
	# Try to find a safe point at a reasonable distance
	var base_flee_distance = 150.0
	var flee_target = global_position + (flee_direction * base_flee_distance)
	
	# Find potential obstacles using raycasts in multiple directions around the flee direction
	var best_direction = flee_direction
	var max_clear_distance = 0
	
	# Check multiple angles around the flee direction
	for angle in [-PI/4, -PI/8, 0, PI/8, PI/4]:
		var test_direction = flee_direction.rotated(angle)
		var clear_distance = get_clear_distance_in_direction(test_direction)
		
		if clear_distance > max_clear_distance:
			max_clear_distance = clear_distance
			best_direction = test_direction
	
	# If we found a better direction with fewer obstacles, use that
	flee_target = global_position + (best_direction * base_flee_distance)
	
	# Make sure the target is within navigable area
	# This would ideally check against the navigation mesh
	var viewport_size = get_viewport_rect().size
	flee_target.x = clamp(flee_target.x, 20, viewport_size.x - 20)
	flee_target.y = clamp(flee_target.y, 20, viewport_size.y - 20)
	
	return flee_target

# Check how far we can go in a direction before hitting something
func get_clear_distance_in_direction(direction: Vector2) -> float:
	var space_state = get_world_2d().direct_space_state
	var max_distance = 200.0
	
	var query = PhysicsRayQueryParameters2D.create(
		global_position, 
		global_position + direction * max_distance,
		1  # Collision mask for walls/obstacles
	)
	
	var result = space_state.intersect_ray(query)
	if result:
		return global_position.distance_to(result.position)
	return max_distance

# Follow the flee path (similar to follow_path but with flee speed)
func follow_flee_path():
	if path_index < path.size():
		# Move to the next point in the path
		var next_point = path[path_index]
		var distance_to_point = global_position.distance_to(next_point)
		
		# If we're close enough to the current point, move to the next one
		if distance_to_point < 5:
			path_index += 1
			
		if path_index < path.size():
			# Calculate direction to the next point
			target_direction = (path[path_index] - global_position).normalized()
			
			# Dynamic speed based on distance to chaser
			var distance_to_chaser = global_position.distance_to(nearby_chaser.global_position)
			var dynamic_speed = flee_speed + max(0, (100 - distance_to_chaser) * 0.7)
			velocity = target_direction * clamp(dynamic_speed, flee_speed, flee_speed + 70)
		else:
			# We've reached the end of the path, calculate a new one
			calculate_flee_path()
	else:
		# Path is empty, calculate a new one
		calculate_flee_path()

# Fallback direct flee behavior (used if pathfinding fails)
func direct_flee_behavior():
	var flee_vector = global_position - nearby_chaser.global_position
	
	# Predictive fleeing: anticipate chaser's future position
	var predicted_chaser_pos = nearby_chaser.global_position + nearby_chaser.velocity * 0.3
	var predicted_flee_vector = global_position - predicted_chaser_pos
	
	# If the predicted position is closer, prioritize it
	if predicted_flee_vector.length() < flee_vector.length():
		flee_vector = predicted_flee_vector

	# Apply smart dodging (slight random angle)
	flee_vector = add_random_dodge(flee_vector)

	# Dynamic speed boost when very close to a chaser
	var distance = global_position.distance_to(nearby_chaser.global_position)
	var dynamic_speed = flee_speed + (200 - distance) * 0.5  
	velocity = flee_vector.normalized() * clamp(dynamic_speed, flee_speed, flee_speed + 50)

# Calculate a path to the target position (for chasers)
func calculate_path_to_target(target_pos: Vector2):
	var map_rid = NavigationServer2D.get_maps()[0]  # Get the first navigation map
	if map_rid.is_valid():
		# Calculate path
		path = NavigationServer2D.map_get_path(map_rid, global_position, target_pos, true)
		path_index = 0
	else:
		# Fallback if navigation is not available
		path = [global_position, target_pos]
		path_index = 0

func follow_path():
	if path_index < path.size():
		# Move to the next point in the path
		var next_point = path[path_index]
		var distance_to_point = global_position.distance_to(next_point)
		
		# If we're close enough to the current point, move to the next one
		if distance_to_point < 5:
			path_index += 1
			
		if path_index < path.size():
			# Calculate direction to the next point
			target_direction = (path[path_index] - global_position).normalized()
			velocity = target_direction * chase_speed
		else:
			# We've reached the end of the path
			if target_runner:
				# Direct movement when we're close
				target_direction = (target_runner.global_position - global_position).normalized()
				velocity = target_direction * chase_speed
	else:
		# Path is finished, calculate a new one
		if target_runner:
			calculate_path_to_target(target_runner.global_position)

func clear_path():
	path = []
	path_index = 0

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
	if (not is_chaser or target_runner == null) and nearby_chaser == null:
		pick_new_direction()  # Keep moving randomly only if not chasing or fleeing
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
		if target_runner:
			calculate_path_to_target(target_runner.global_position)  # Calculate initial path

func _on_detection_area_body_exited(body):
	if body == target_runner:
		target_runner = null  # Stop chasing if runner leaves radius
		clear_path()  # Clear the path when target is lost

func _on_flee_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser and not is_chaser:
		nearby_chaser = body  # Start fleeing
		calculate_flee_path()  # Calculate initial flee path when first seeing a chaser

func _on_flee_area_body_exited(body):
	if body == nearby_chaser:
		nearby_chaser = null  # Stop fleeing if chaser leaves radius
		clear_path()  # Clear the flee path

func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 100  # Slight speed boost
		target_runner = null  # Stop chasing when turned into a chaser
		nearby_chaser = null  # Stop fleeing when becoming a chaser
		clear_path()  # Clear any existing path
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
