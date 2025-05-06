extends Node2D

@export var speed: float = 30.0
@export var left_limit: float = 100.0
@export var right_limit: float = 800.0

var direction := 1  # 1 for right, -1 for left

func _ready():
	$AnimatedSprite2D.play("WalkSide")  # Use your animation name

func _process(delta):
	position.x += direction * speed * delta

	if position.x > right_limit:
		direction = -1
		$AnimatedSprite2D.flip_h = true
	elif position.x < left_limit:
		direction = 1
		$AnimatedSprite2D.flip_h = false
