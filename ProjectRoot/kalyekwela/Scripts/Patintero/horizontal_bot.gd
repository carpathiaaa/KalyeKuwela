extends CharacterBody2D

@onready var target_player = get_parent().get_node("main_player")
@onready var main_patintero = $"../"
@onready var enemy_animation = $AnimatedSprite2D
var enemy_speed = 10 # base speed of horizontal enemy (scales with game level)

func _ready() -> void:
	position.y = clamp(position.y, -30, -30)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var enemy_direction = (target_player.position - position ).normalized() 
	velocity = enemy_direction * enemy_speed * (main_patintero.level + 1) * 2 
	velocity.y = 0
	position.x = clamp(position.x, -210, 250 + (470 * main_patintero.level))
	move_and_slide()
	if enemy_direction.length() > 0:
		enemy_direction = enemy_direction.normalized()
		update_animation(enemy_direction)
	move_and_slide()

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		enemy_animation.play("WalkSide")
		enemy_animation.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		enemy_animation.play("WalkFront")
	else:
		enemy_animation.play("WalkBack")
