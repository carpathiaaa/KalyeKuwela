extends Node2D
@onready var parent_node = $"../"
@onready var coin_sfx = $"../coin_sfx"
@onready var main_patintero = $"../../../"

# detect if player touches coin
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("main_player"):
		main_patintero.add_level_coins((main_patintero.level / 2) + 1)
		parent_node.queue_free()
