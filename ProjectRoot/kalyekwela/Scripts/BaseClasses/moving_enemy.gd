class_name MovingEnemy
extends BaseEnemy


@export var target_player : Player = null
var base_speed : float = 100.0 # Default enemy speed
var level_speed : float
var tracker = TrackingModule.new(self)
var random_number = RandomNumberGenerator.new()

func set_target(new_target : Player, new_speed : float) -> void:
	if new_target is Player:
		target_player = new_target
		tracker.track_target(target_player)
		level_speed = new_speed
	else:
		push_error("Invalid target node")

func update_velocity(new_velocity : Vector2, delta: float) -> void:
	velocity.y = new_velocity.y  # float towards the target
	move_and_slide()

func simple_float() -> Vector2:
	return tracker.find_target_position() * (base_speed + (0.5 * level_speed))

func horizontal_float() -> Vector2:
	return Vector2(tracker.find_target_position().x, self.position.y) * (base_speed + (0.5 * level_speed))

func vertical_float() -> Vector2:
	return Vector2(self.position.x, tracker.find_target_position().y) * (base_speed + (1 + 0.5 * level_speed))
