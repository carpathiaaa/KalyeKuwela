class_name RandomFloatEnemy
extends BaseEnemy

@onready var enemy_sprite = $AnimatedSprite2D
var rng = RandomNumberGenerator.new()

# Movement parameters
var float_speed: float = 1.5
var amplitude: float = 50.0
var frequency: float = 1.0
var base_y: float = 0.0
var time: float = 0.0
var random_offset: float = 0.0

func _ready() -> void:
	rng.randomize()
	base_y = position.y
	random_offset = rng.randf_range(0, 2 * PI)  # Random starting point in wave
	# Randomize movement parameters
	float_speed = rng.randf_range(1.0, 2.0)
	amplitude = rng.randf_range(40.0, 80.0)
	frequency = rng.randf_range(0.8, 1.2)

func _physics_process(delta: float) -> void:
	time += delta
	
	# Sine wave-based vertical movement
	var vertical_offset = sin(time * frequency + random_offset) * amplitude
	position.y = base_y + vertical_offset
	
	# Random speed variation
	float_speed += rng.randf_range(-0.1, 0.1)
	float_speed = clamp(float_speed, 1.0, 2.0)
	
	# Random horizontal drift
	position.x += rng.randf_range(-0.5, 0.5)
	
	# Update animation based on direction
	update_animation(vertical_offset)
	move_and_slide()

func update_animation(y_offset: float):
	if abs(y_offset) > amplitude * 0.8:  # Change animation near movement extremes
		enemy_sprite.play("WalkBack" if y_offset > 0 else "WalkFront")
	else:
		enemy_sprite.play("WalkFront")  # Add a neutral animation
