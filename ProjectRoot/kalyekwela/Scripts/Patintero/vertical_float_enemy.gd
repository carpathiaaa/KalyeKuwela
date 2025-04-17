class_name VerticalFloatEnemy
extends MovingEnemy

@onready var enemy_sprite = $Sprite2D
var direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	update_velocity(simple_float(), delta)
	direction = velocity
	
	if direction.length() > 0:
		direction = direction.normalized()
		update_animation(direction)
	move_and_slide()

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		enemy_sprite.play("WalkSide")
		enemy_sprite.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		enemy_sprite.play("WalkFront")
	else:
		enemy_sprite.play("WalkBack")
