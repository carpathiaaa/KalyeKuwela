class_name MovingEnemy
extends BaseEnemy


@export var target_player : Player = null
var speed : float = 50.0 # Default enemy speed
var tracker = TrackingModule.new(self)
var random_number = RandomNumberGenerator.new()

func set_target(new_target : Player, new_speed : float) -> void:
	if new_target is Player:
		target_player = new_target
		tracker.track_target(target_player)
		speed = new_speed
	else:
		push_error("Invalid target node")

func update_velocity(new_velocity : Vector2, delta: float) -> void:
	velocity.y = new_velocity.y  # float towards the target
	move_and_slide()

func simple_float() -> Vector2:
	return tracker.find_target_position() * speed

func horizontal_float() -> Vector2:
	return Vector2(tracker.find_target_position().x, self.position.y) * speed

func vertical_float() -> Vector2:
	return Vector2(self.position.x, tracker.find_target_position().y) * speed

func random_vertical_float() -> Vector2:
	var noise_offset = 0.0
	var to_top : bool = false
	# Use noise for smoother randomness
	noise_offset += randf_range(1, 10)
	var random_offset = sin(noise_offset) * 10  # Smooth wave pattern
	if to_top:
		random_offset *= -1
	if position.y < 130:
		to_top = false
		random_offset -= 1
	elif position.y > -130:
		to_top = true
		random_offset += 1
	return Vector2(0, random_offset) * speed


func loop_vertical_float(min_position_y: int, max_position_y: int) -> Vector2:
	# Use global_position if boundaries are in world space
	var current_y = self.global_position.y  # or self.position.y for local space
	
	# Determine direction (1 = down, -1 = up)
	var direction := 0.0
	
	if current_y > max_position_y:
		direction = -1.0  # Move up (toward lower Y)
	elif current_y < min_position_y:
		direction = 1.0   # Move down (toward higher Y)
	else:
		# Continue moving in the current direction (optional)
		# Example: direction = 1.0 for constant downward motion
		return Vector2.ZERO
	
	# Return velocity: direction * speed
	return Vector2(0, direction) * speed
