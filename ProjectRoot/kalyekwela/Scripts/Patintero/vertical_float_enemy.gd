class_name VerticalFloatEnemy
extends BaseEnemy

@onready var enemy_sprite = $Sprite2D
var direction = Vector2.ZERO

@export var target_player : Player = null
var base_speed : float = 50 # Default enemy speed
var level_speed
var tracker = TrackingModule.new(self)
var random_number = RandomNumberGenerator.new()

func update_velocity(new_velocity : Vector2, delta: float) -> void:
	velocity.y = new_velocity.y  # float towards the target
	move_and_slide()

func _physics_process(delta: float) -> void:
	velocity = vertical_float()
	direction = velocity
	
	if direction.length() > 0:
		direction = direction.normalized()
		update_animation(direction)
	move_and_slide()

func vertical_float() -> Vector2:
	return Vector2(self.position.x, tracker.find_target_position().y) * base_speed * (1 + (level_speed * 0.5))

func set_target(new_target : Player, new_speed : float) -> void:
	if new_target is Player:
		target_player = new_target
		tracker.track_target(target_player)
		level_speed = new_speed 
	else:
		push_error("Invalid target node")

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		enemy_sprite.play("WalkSide")
		enemy_sprite.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		enemy_sprite.play("WalkFront")
	else:
		enemy_sprite.play("WalkBack")
