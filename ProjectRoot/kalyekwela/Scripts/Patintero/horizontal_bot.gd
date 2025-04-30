extends CharacterBody2D

@onready var target_player = get_parent().get_node("main_player")
@onready var main_patintero = $"../"
@onready var enemy_animation = $AnimatedSprite2D
var base_speed : float = 40.0 # base speed of horizontal enemy (scales with game level)
var game_level = 1

func _ready() -> void:
	get_parent().change_level.connect(update_level)
	position.y = clamp(position.y, -30, -30)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var enemy_direction = (target_player.position - position ).normalized() 
	velocity = enemy_direction * (base_speed + game_level * 0.5)
	velocity.y = 0
	position.x = clamp(position.x, -210, 250 + (470 * game_level))
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

func update_level(current_level : int) -> void:
	game_level = current_level
