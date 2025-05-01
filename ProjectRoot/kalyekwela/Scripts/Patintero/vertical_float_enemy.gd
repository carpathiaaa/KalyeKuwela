class_name VerticalFloatEnemy
extends BaseEnemy

@onready var enemy_sprite = $Sprite2D
@onready var target : Player
var direction = Vector2.ZERO
var tracker = TrackingModule.new(self)
var random_number = RandomNumberGenerator.new()
var base_speed : float = 0.4
var level_speed : float


func set_target(new_target : Player, new_speed : float) -> void:
	if new_target is Player:
		target = new_target
		tracker.track_target(target)
		level_speed = new_speed
	else:
		push_error("Invalid target node")


func _physics_process(delta: float) -> void:
	velocity = vertical_float()
	direction = velocity
	
	if direction.length() > 0:
		direction = direction.normalized()
		update_animation(direction)
	move_and_slide()
	
func vertical_float() -> Vector2:
	return Vector2(0, target.position.y - position.y) * (base_speed * (1 + level_speed))

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if direction.y > 0:
		enemy_sprite.play("WalkFront")
	else:
		enemy_sprite.play("WalkBack")
