extends Area2D

func _on_area_entered(area: Area2D) -> void:  # Detect if any entity entered score line
	if area.is_in_group("main_player"): 
		queue_free()  # Schedule this Area2D node for deletion
