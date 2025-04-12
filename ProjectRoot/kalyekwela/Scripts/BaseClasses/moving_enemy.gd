class_name MovingEnemy
extends BaseEnemy


@export var target_player : Player = null
var speed : float = 0.0
var tracker = TrackingComponent.new(self)

func set_target(new_target : Player, new_speed : float) -> void:
	if new_target is Player:
		target_player = new_target
		tracker.track_target(target_player)
		speed = new_speed
	else:
		push_error("Invalid target type")

func update_velocity(direction : Vector2, delta: float) -> void:
	var current_velocity = direction * speed 
	velocity = current_velocity  # float towards the target
	move_and_slide()

func simple_float() -> Vector2:
	return tracker.find_target_position()

func horizontal_float() -> Vector2:
	return Vector2(tracker.find_target_position().x, self.position.y)

func vertical_float() -> void:
	return Vector2(self.position.x, tracker.find_target_position().y)
