class_name RandomFloatEnemy
extends BaseEnemy

@onready var enemy_animation = $AnimatedSprite2D
var random_number = RandomNumberGenerator.new()

# Movement parameters
var float_speed: float = 150

# Y-axis boundaries
var min_y := -190
var mid_y := -30
var max_y := 130

var current_min := generate_min_y()
var current_max := generate_max_y()
var enemy_direction := 0

func _physics_process(delta: float) -> void:
	# Vertical movement logic
	float_speed = randf_range(60.0, 200.0)
	if position.y >= current_max:
		enemy_direction = -1  # Move down
		current_min = generate_min_y()
		update_animation(velocity)
	elif position.y <= current_min:
		enemy_direction = 1   # Move up
		current_max = generate_max_y()
		update_animation(velocity)

	velocity = Vector2(0, enemy_direction * float_speed)
	move_and_slide()
	
	# Update animation with actual velocity

func generate_min_y() -> int:
	return random_number.randi_range(min_y, mid_y + 20)  # Low to high

func generate_max_y() -> int:
	return random_number.randi_range(mid_y - 20, max_y)  # Already correct

# 🔄 Update animation based on movement direction
func update_animation(direction: Vector2):
	var target_anim := "WalkBack"  # Default animation
	
	if direction.y > 0:
		target_anim = "WalkBack"
	elif direction.y < 0:
		target_anim = "WalkFront"
	
	# Only change animation if needed
	if enemy_animation.animation != target_anim:
		enemy_animation.play(target_anim)
