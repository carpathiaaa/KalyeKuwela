extends MarginContainer

@onready var Patintero = $Category/CategoryContainer/Patintero
@onready var TumbangPreso = $Category/CategoryContainer/TumbangPreso
@onready var BenteUno = $Category/CategoryContainer/BenteUno

@onready var label1 = $HowToPlayBackground/HowToPlayBackground2/MarginContainer/HowToPlayBackground3/RichTextLabel1
@onready var label2 = $HowToPlayBackground/HowToPlayBackground2/MarginContainer/HowToPlayBackground3/RichTextLabel2
@onready var label3 = $HowToPlayBackground/HowToPlayBackground2/MarginContainer/HowToPlayBackground3/RichTextLabel3

@onready var click_sound = $"../ClickSound"
@onready var click_sound_2 = $"../ClickSound2"

func _ready():
	label1.visible = true
	label2.visible = false
	label3.visible = false

func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()

func _on_patintero_pressed() -> void:
	play_click_sound()
	label1.visible = true
	label2.visible = false
	label3.visible = false

func _on_tumbang_preso_pressed() -> void:
	play_click_sound()
	label1.visible = false
	label2.visible = true
	label3.visible = false

func _on_bente_uno_pressed() -> void:
	play_click_sound()
	label1.visible = false
	label2.visible = false
	label3.visible = true
