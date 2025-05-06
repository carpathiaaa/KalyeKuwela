extends Control

@onready var click_sound = $ClickSound
@onready var click_sound_2 = $ClickSound2

func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()

func _on_return_button_pressed() -> void:
	play_click_sound_2()
	await click_sound_2.finished
	CompactTransition.load_scene('res://Scenes/MainMenu/menu.tscn')
