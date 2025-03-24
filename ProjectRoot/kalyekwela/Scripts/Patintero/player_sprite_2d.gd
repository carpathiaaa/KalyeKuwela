extends AnimatedSprite2D

var players = {
	0: preload("res://Assets/Art/Characters/Frames/Juan_Frames.tres"),
	1: preload("res://Assets/Art/Characters/Frames/Maria_Frames.tres"),
	2: preload("res://Assets/Art/Characters/Frames/Antionio_Frames.tres"),
	3: preload("res://Assets/Art/Characters/Frames/Carlo_Frames.tres"),
	4: preload("res://Assets/Art/Characters/Frames/Reyna_Frames.tres"),
	5: preload("res://Assets/Art/Characters/Frames/Tala_Frames.tres"),
}

func _ready() -> void:
	# Ensure the selected character is reflected in-game
	update_character(GlobalData.PlayerSelect)

func update_character(selected_index: int):
	if selected_index in players:
		self.sprite_frames = players[selected_index]
		self.play("IdleFront")  # Ensure animation starts (adjust to your animation names)
