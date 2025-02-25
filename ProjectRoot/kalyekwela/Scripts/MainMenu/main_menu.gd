extends Control

#@onready var patintero_button = $GameButtonsContainer/PatinteroButton
#@onready var tumbang_preso_button = $GameButtonsContainer/TumbangPresoButton
@onready var bente_uno_button = $GameButtonsContainer/BenteUno

func _ready():
	#patintero_button.pressed.connect(start_patintero)
	#tumbang_preso_button.pressed.connect(start_tumbang_preso)
	bente_uno_button.pressed.connect(start_bente_uno)

#func start_patintero():
	#get_tree().change_scene_to_file("res://scenes/patintero.tscn")
#
#func start_tumbang_preso():
	#get_tree().change_scene_to_file("res://scenes/tumbang_preso.tscn")

func start_bente_uno():
	get_tree().change_scene_to_file("res://Scenes/BenteUno/main.tscn")
