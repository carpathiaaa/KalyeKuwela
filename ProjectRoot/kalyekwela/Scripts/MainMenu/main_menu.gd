extends Control

#@onready var patintero_button = $GameButtonsContainer/PatinteroButton
#@onready var tumbang_preso_button = $GameButtonsContainer/TumbangPresoButton
@onready var bente_uno_button = $GameButtonsContainer/BenteUno

@onready var currency_display = $CurrencyDisplay
@onready var xp_bar = $XPBar

func update_ui():
	currency_display.text = "Coins: " + str(GlobalData.coins)
	# Update XP bar based on current level progress
	var xp_required = GlobalData.get_xp_required(GlobalData.level)
	xp_bar.value = float(GlobalData.xp) / xp_required * 100  # Set bar percentage

func _ready():
	GlobalData.load_data()  # Load saved data
	update_ui()  # Ensure UI reflects loaded data
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
