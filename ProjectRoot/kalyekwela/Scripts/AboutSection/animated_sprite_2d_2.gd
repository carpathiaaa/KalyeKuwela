extends Node2D

@export var speed: float = 60.0
@export var move_duration: float = 10.0  # time in seconds before switching direction

var direction := 1  # 1 = right, -1 = left
var move_timer := 0.0

func _ready():
	$".".play("WalkSide")
	$".".flip_h = false
	move_timer = move_duration

func _process(delta):
	position.x += direction * speed * delta
	move_timer -= delta

	if move_timer <= 0.0:
		direction *= -1  # switch direction
		move_timer = move_duration
		$".".flip_h = (direction == -1)
