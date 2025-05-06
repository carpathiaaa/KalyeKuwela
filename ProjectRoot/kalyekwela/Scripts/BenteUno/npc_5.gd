extends CharacterBody2D

@export var speed: float = 100
var is_chaser: bool = false
var target_direction: Vector2
var target_runner: CharacterBody2D = null  # Chasers will chase this
var nearby_chaser: CharacterBody2D = null  # Runners will flee from this
var chase_speed: float = 80  # Further reduced chaser speed
var flee_speed: float = 140  # Increased flee speed to make runners harder to catch

# New variables for strategic fleeing behavior
var other_runners: Array = []  # Track other runners in the scene
var seeking_runners: bool = false  # Whether we're actively seeking other runners
var runner_seek_timer: float = 0  # Timer to periodically check for runners
var runner_seek_interval: float = 1.0  # How often to check for runners

var path: Array = []
var path_index: int = 0
var pathfinding_enabled: bool = true
var pathfinding_timer: float = 0
var pathfinding_update_time: float = 0.5  # Update path every 0.5 seconds

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
	# Update the runner seek timer
	if nearby_chaser:
		runner_seek_timer += delta
		if runner_seek_timer >= runner_seek_interval:
			runner_seek_timer = 0
			find_all_runners()
	
	if nearby_chaser:
		# First priority: flee from chaser
		var flee_vector = global_position - nearby_chaser.global_position
		
		# Predictive fleeing: anticipate chaser's future position
		var predicted_chaser_pos = nearby_chaser.global_position + nearby_chaser.velocity * 0.3
		var predicted_flee_vector = global_position - predicted_chaser_pos
		
		# If the predicted position is closer, prioritize it
		if predicted_flee_vector.length() < flee_vector.length():
			flee_vector = predicted_flee_vector

		# Check if there are other runners to seek
		if other_runners.size() > 0:
			# Find the best runner to use as bait/diversion
			var best_runner_pos = find_best_runner_position()
			if best_runner_pos != Vector2.ZERO:
				# Try to move toward other runners while still fleeing
				var runner_direction = (best_runner_pos - global_position).normalized()
				
				# Blend flee direction with runner-seeking direction
				# Weight depends on how close the chaser is
				var chaser_distance = global_position.distance_to(nearby_chaser.global_position)
				var flee_weight = 1.0 - clamp(chaser_distance / 150.0, 0.0, 0.7)
				var runner_weight = 1.0 - flee_weight
				
				# Combined direction: flee from chaser but also move toward other runners
				var combined_direction = (flee_vector.normalized() * flee_weight + 
										runner_direction * runner_weight).normalized()
				
				# Check if this direction is blocked
				if is_path_blocked(combined_direction):
					combined_direction = find_alternate_escape_route(combined_direction)
				
				# Add a small random element for unpredictability
				combined_direction = add_random_dodge(combined_direction)
				
				# Dynamic speed boost when very close to a chaser
				var dynamic_speed = flee_speed + (200 - chaser_distance) * 0.5
				velocity = combined_direction * clamp(dynamic_speed, flee_speed, flee_speed + 50)
			else:
				# No good runners to seek, just flee normally
				standard_flee_behavior(flee_vector)
		else:
			# No other runners to seek, just flee normally
			standard_flee_behavior(flee_vector)
	else:
		# Default wandering movement
		velocity = target_direction * speed
		seeking_runners = false

# Standard fleeing behavior when not seeking other runners
func standard_flee_behavior(flee_vector):
	# Check for walls in the flee direction
	if is_path_blocked(flee_vector.normalized()):
		flee_vector = find_alternate_escape_route(flee_vector)
	
	# Apply smart dodging (slight random angle)
	flee_vector = add_random_dodge(flee_vector)

	# Dynamic speed boost when very close to a chaser
	var distance = global_position.distance_to(nearby_chaser.global_position)
	var dynamic_speed = flee_speed + (200 - distance) * 0.5  
	velocity = flee_vector.normalized() * clamp(dynamic_speed, flee_speed, flee_speed + 50)

# Find all runner NPCs in the scene
func find_all_runners():
	other_runners.clear()
	
	# Get all NPCs in the scene
	var npcs = get_tree().get_nodes_in_group("npc")
	
	for npc in npcs:
		# Skip yourself and chasers
		if npc != self and npc is CharacterBody2D and not npc.is_chaser:
			other_runners.append(npc)

# Find the best runner to use as bait/diversion
func find_best_runner_position() -> Vector2:
	if other_runners.size() == 0:
		return Vector2.ZERO
	
	var best_runner = null
	var best_score = -INF
	
	for runner in other_runners:
		# Skip invalid runners
		if not is_instance_valid(runner) or runner.is_chaser:
			continue
		
		# Calculate the score for this runner
		var score = calculate_runner_score(runner)
		
		if score > best_score:
			best_score = score
			best_runner = runner
	
	if best_runner and best_score > 0:
		return best_runner.global_position
	else:
		return Vector2.ZERO

# Calculate a score for each runner based on strategic factors
func calculate_runner_score(runner) -> float:
	var score = 0.0
	
	# Distance from self (closer is better, but not too close)
	var self_distance = global_position.distance_to(runner.global_position)
	if self_distance < 20:  # Too close, not helpful
		score -= 100
	elif self_distance > 300:  # Too far, not practical
		score -= 50
	else:
		score += 100 - (self_distance / 3)
	
	# Distance from chaser (farther is better)
	var chaser_distance = nearby_chaser.global_position.distance_to(runner.global_position)
	score += chaser_distance * 0.5
	
	# Position relative to chaser (prefer runners that are in a different direction from the chaser)
	var self_to_chaser = (nearby_chaser.global_position - global_position).normalized()
	var self_to_runner = (runner.global_position - global_position).normalized()
	var dot_product = self_to_chaser.dot(self_to_runner)
	
	# If dot product is negative, runner is in opposite direction from chaser (good)
	if dot_product < 0:
		score += 100 * abs(dot_product)
	
	# Check if there's a clear path to the runner
	if pathfinding_enabled:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, runner.global_position, 1)
		var result = space_state.intersect_ray(query)
		if result.size() > 0:
			score -= 50  # Path is blocked
	
	return score

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

# Calculate a path to the target position
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
		if target_runner:
			calculate_path_to_target(target_runner.global_position)  # Calculate initial path

func _on_detection_area_body_exited(body):
	if body == target_runner:
		target_runner = null  # Stop chasing if runner leaves radius
		clear_path()  # Clear the path when target is lost

func _on_flee_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser and not is_chaser:
		nearby_chaser = body  # Start fleeing
		# When a chaser is detected, start looking for other runners
		find_all_runners()

func _on_flee_area_body_exited(body):
	if body == nearby_chaser:
		nearby_chaser = null  # Stop fleeing if chaser leaves radius
		seeking_runners = false  # Stop seeking runners when not being chased

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
