extends SpriteSelection

func _ready() -> void:
	# Ensure the selected character is reflected in-game
	update_character(GlobalData.PlayerSelect)
