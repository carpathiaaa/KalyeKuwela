extends CharacterBody2D

@onready var target_player = get_node("/root/Patintero/main_player/body")

var enemy_speed = 50 # base speed of horizontal enemy
var random_number = RandomNumberGenerator.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	var enemy_direction = (target_player.position - position).normalized()
	velocity = enemy_direction * enemy_speed
	velocity.x = 0
	move_and_slide()
