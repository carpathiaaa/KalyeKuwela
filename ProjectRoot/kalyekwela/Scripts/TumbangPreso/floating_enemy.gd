extends BaseEnemy

@onready var player = $"../player"
@onready var enemy_animation = $AnimatedSprite2D  # Renamed for clarity
var new_speed: float = 100.0

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if player:
		# Calculate direction TOWARDS player (was moving away before)
		direction = (player.position - position).normalized()
		# Set velocity towards player
		velocity = direction * new_speed
		# Update animations based on movement direction
		update_animation(direction)
		move_and_slide()

func update_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		enemy_animation.play("WalkSide")
		enemy_animation.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		enemy_animation.play("WalkFront")
	else:
		enemy_animation.play("WalkBack")
