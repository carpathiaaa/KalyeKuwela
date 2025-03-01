extends Control

#@onready var patintero_button = $GameButtonsContainer/PatinteroButton
#@onready var tumbang_preso_button = $GameButtonsContainer/TumbangPresoButton
@onready var bente_uno_button = $MarginContainer/GameButtonsContainer/BenteUno

@onready var currency_display = $CurrencyDisplay
@onready var xp_bar = $XPBar

@export var settings_popup: MarginContainer
@export var inventory_popup: MarginContainer
@export var shop_popup: MarginContainer

var current_open_popup: Control = null  # Tracks the currently open sidebar

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

func start_bente_uno():
	get_tree().change_scene_to_file("res://Scenes/BenteUno/main.tscn")

# Function to manage popups (ensuring only one is open at a time)
func toggle_popup(popup: Control):
	if current_open_popup and current_open_popup != popup:
		current_open_popup.visible = false  # Close previous popup
	
	# Toggle the new popup's visibility
	popup.visible = !popup.visible  
	current_open_popup = popup if popup.visible else null  # Update tracking

func _on_toggle_settings_button_pressed():
	toggle_popup(settings_popup)

func _on_toggle_inventory_button_pressed():
	toggle_popup(inventory_popup)

func _on_toggle_shop_button_pressed():
	toggle_popup(shop_popup)
