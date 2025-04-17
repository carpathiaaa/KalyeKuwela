class_name SpriteSelection
extends AnimatedSprite2D

var players = {
	0: preload("res://Assets/Art/Characters/Frames/Juan_Frames.tres"),
	1: preload("res://Assets/Art/Characters/Frames/Maria_Frames.tres"),
	2: preload("res://Assets/Art/Characters/Frames/Antionio_Frames.tres"),
	3: preload("res://Assets/Art/Characters/Frames/Carlo_Frames.tres"),
	4: preload("res://Assets/Art/Characters/Frames/Reyna_Frames.tres"),
	5: preload("res://Assets/Art/Characters/Frames/Tala_Frames.tres"),
}

var random_number = RandomNumberGenerator.new()

	
	# Ensure the selected character is reflected in-game
func update_character(selected_index: int):
	if selected_index in players:
		self.sprite_frames = players[selected_index]
		self.play("IdleFront")  # Ensure animation starts (adjust to your animation names)

func update_side_character(selected_index: int) -> void:
	var main_sprite = selected_index
	while main_sprite == selected_index:
		main_sprite = random_number.randi_range(0, 5)
	if main_sprite in players:
		self.sprite_frames = players[main_sprite]
		self.play("IdleFront")  # Ensure animation starts (adjust to your animation names)
