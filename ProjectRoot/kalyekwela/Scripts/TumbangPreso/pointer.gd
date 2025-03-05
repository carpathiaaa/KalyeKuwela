extends CharacterBody2D

@onready var time_bar = $".."

var pointer_speed = 100
var pointer_direction = 1
var time_bar_boundary = 100

func update_boundary(new_boundary: float) -> void:
	time_bar_boundary = new_boundary

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("left_boundary"):
		pointer_direction = 1

	if area.is_in_group("right_boundary"):
		pointer_direction = -1
		
	if area.is_in_group("success_area"):
		time_bar.success = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("success_area"):
		time_bar.success = false

func _physics_process(delta: float) -> void:
	velocity.x = pointer_speed * pointer_direction
	move_and_slide()
