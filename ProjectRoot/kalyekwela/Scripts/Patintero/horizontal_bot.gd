extends CharacterBody2D

@onready var target_player = get_parent().get_node("main_player/body")
@onready var main_patintero = $"../"
var enemy_speed = 75# base speed of horizontal enemy (scales with game level)

func _ready() -> void:
	position.y = clamp(position.y, -30, -30)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var enemy_direction = (target_player.position - position ).normalized() 
	velocity = enemy_direction * enemy_speed * (main_patintero._level + 1) * 2 
	velocity.y = 0
	position.x = clamp(position.x, -210, 250 + (470 * main_patintero._level))
	move_and_slide()
