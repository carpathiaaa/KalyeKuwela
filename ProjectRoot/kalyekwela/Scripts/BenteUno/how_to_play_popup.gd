extends MarginContainer

@onready var BenteUno = $Category/CategoryContainer/BenteUno


@onready var label3 = $HowToPlayBackground/HowToPlayBackground2/MarginContainer/HowToPlayBackground3/RichTextLabel3

@onready var click_sound = $"../ClickSound"
@onready var click_sound_2 = $"../ClickSound2"

@onready var HowToPlayPopup = $"."

func _ready():
	label3.visible = true

func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()

func _on_bente_uno_pressed() -> void:
	play_click_sound()
	label3.visible = true
