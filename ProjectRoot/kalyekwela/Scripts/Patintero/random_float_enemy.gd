class_name RandomFloatEnemy
extends BaseEnemy

@onready var enemy_animation: AnimatedSprite2D = $AnimatedSprite2D

# Random number generator with proper seeding
var rng := RandomNumberGenerator.new()

# Movement parameters
var float_speed: float = 150.0
var current_target_y: float = 0.0
var movement_direction: int = 0

# Y-axis boundaries (using float values for smoother movement)
@export var min_y: float = -190.0
@export var mid_y: float = -30.0
@export var max_y: float = 130.0

func _ready() -> void:
	rng.randomize()
	_set_new_target()

func _physics_process(delta: float) -> void:
	# Calculate movement
	var target_velocity = Vector2(0, movement_direction * float_speed)
	velocity = velocity.lerp(target_velocity, delta * 5)
	
	# Update position and check boundaries
	move_and_slide()
	_check_boundaries()
	update_animation(velocity)

func _set_new_target() -> void:
	# Set new random speed when changing direction
	float_speed = rng.randf_range(60.0, 200.0)
	
	# Generate new target Y within valid range
	if movement_direction == 1:  # Moving up
		current_target_y = rng.randf_range(mid_y, max_y - rng.randi_range(0, 30))
	else:  # Moving down
		current_target_y = rng.randf_range(min_y + rng.randi_range(0, 30), mid_y)
	
	# Determine direction based on current position
	movement_direction = 1 if global_position.y < current_target_y else -1
func _check_boundaries() -> void:
	# Check if reached target area
	if (movement_direction == 1 && global_position.y >= current_target_y) || (movement_direction == -1 && global_position.y <= current_target_y):
		_set_new_target()
# 🔄 Update animation based on movement direction
func update_animation(direction: Vector2):
	var target_anim := "WalkBack"  # Default animation
	
	if direction.y > 0:
		target_anim = "WalkFront"
	elif direction.y < 0:
		target_anim = "WalkBack"
	
	# Only change animation if needed
	if enemy_animation.animation != target_anim:
		enemy_animation.play(target_anim)
