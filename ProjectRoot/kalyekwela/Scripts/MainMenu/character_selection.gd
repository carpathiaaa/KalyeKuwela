extends Control
@onready var click_sound = $"../ClickSound"

var all_characters = ["Juan", "Maria", "Antonio", "Carlo", "Reyna", "Tala"]
var default_characters = ["Juan", "Maria"]  # Default unlocked characters

func _process(delta) -> void:
	if GlobalData.PlayerSelect < all_characters.size():
		get_node("AvatarIcon").play(all_characters[GlobalData.PlayerSelect])

func play_click_sound():
	if click_sound:
		click_sound.play()

func _on_right_arrow_pressed() -> void:
	play_click_sound()
	var new_index = (GlobalData.PlayerSelect + 1) % all_characters.size()

	# Find the next unlocked character, looping if necessary
	while not is_character_unlocked(all_characters[new_index]):
		new_index = (new_index + 1) % all_characters.size()
	
	GlobalData.PlayerSelect = new_index

func _on_left_arrow_pressed() -> void:
	play_click_sound()
	var new_index = (GlobalData.PlayerSelect - 1 + all_characters.size()) % all_characters.size()

	# Find the previous unlocked character, looping if necessary
	while not is_character_unlocked(all_characters[new_index]):
		new_index = (new_index - 1 + all_characters.size()) % all_characters.size()
	
	GlobalData.PlayerSelect = new_index

func is_character_unlocked(character_name: String) -> bool:
	return character_name in default_characters or character_name in GlobalData.owned_characters
