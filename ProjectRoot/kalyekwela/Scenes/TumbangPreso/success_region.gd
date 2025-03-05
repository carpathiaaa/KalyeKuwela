extends Area2D

@onready var region_indicator = $region_indicator

func change_position(new_position: int) -> void:
	region_indicator.position.x = new_position
	position.x = region_indicator.position.x
