extends Node2D

@export var speed: float = 30.0
@export var left_limit: float = 100.0
@export var right_limit: float = 800.0

var direction := 1  # 1 for right, -1 for left

func _ready():
	$".".play("IdleFront")  # Use your animation name

func _process(delta):
	pass
