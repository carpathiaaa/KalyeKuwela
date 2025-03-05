extends Node2D

@onready var main = $"../" # connect to main scene
@onready var background = $background # connect to background 
@onready var pointer = $pointer # connect to pointer
@onready var left_boundary = $left_boundary
@onready var right_boundary = $right_boundary
@onready var success_region = $success_region

var random_number = RandomNumberGenerator.new()
var success : bool = false

func _ready() -> void:
	# generate a random seed based on current time
	random_number.randomize()
	update_time_bar(10, 700)

func update_time_bar(length: int, speed: int) -> void:
	pointer.pointer_speed = speed
	left_boundary.position.x -= length/2
	right_boundary.position.x += length/2
	background.position.x = left_boundary.position.x
	background.size.x += length
	success_region.change_position(random_number.randf_range(-length, length))
