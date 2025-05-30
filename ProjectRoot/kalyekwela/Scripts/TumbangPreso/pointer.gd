extends AnimatableBody2D

@onready var timed_click_bar = $".."

func _on_pointer_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("acceptance_region"):
		timed_click_bar.change_state(true)

func _on_pointer_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("acceptance_region"):
		timed_click_bar.change_state(false)
