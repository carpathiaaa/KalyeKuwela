extends Control

@onready var patintero_button = $MarginContainer/GameButtonsContainer/Patintero
@onready var tumbang_preso_button = $MarginContainer/GameButtonsContainer/TumbangPreso
@onready var bente_uno_button = $MarginContainer/GameButtonsContainer/BenteUno
@onready var currency_display = $CurrencyDisplay
@onready var xp_bar = $XPBar

@export var settings_popup: MarginContainer
@export var inventory_popup: MarginContainer
@export var shop_popup: MarginContainer

var current_open_popup: Control = null  # Tracks the currently open sidebar
var is_animating: bool = false  # Prevent multiple fast clicks

func update_ui():
	currency_display.text = "Coins: " + str(GlobalData.coins)
	var xp_required = GlobalData.get_xp_required(GlobalData.level)
	xp_bar.value = float(GlobalData.xp) / xp_required * 100  # Set bar percentage

func _ready():
	GlobalData.load_data()  # Load saved data
	update_ui()  # Ensure UI reflects loaded data
	patintero_button.pressed.connect(start_patintero)
	tumbang_preso_button.pressed.connect(start_tumbang_preso)
	bente_uno_button.pressed.connect(start_bente_uno)

func start_patintero():
	get_tree().change_scene_to_file("res://Scenes/Patintero/main.tscn")

func start_tumbang_preso():
	get_tree().change_scene_to_file("res://Scenes/TumbangPreso/main.tscn")

func start_bente_uno():
	get_tree().change_scene_to_file("res://Scenes/BenteUno/main.tscn")

# Function to manage popups (ensuring only one is open at a time)
#func toggle_popup(popup: Control):
#	if current_open_popup and current_open_popup != popup:
#		current_open_popup.visible = false  # Close previous popup

# Function to toggle popups properly
func toggle_popup(new_popup: Control):
	# Prevent clicking while animation is running
	if is_animating:
		return

	# If clicking the already open popup, play the exit animation and close it
	if new_popup == current_open_popup:
		close_popup(new_popup)
		return

	# If another popup is open, close it immediately without animation
	if current_open_popup:
		current_open_popup.visible = false  

	# Open the new popup and play the open animation
	new_popup.visible = true
	var anim_player = new_popup.get_node_or_null("AnimationInOut") as AnimationPlayer
	if anim_player:
		is_animating = true
		anim_player.play("TransitionIn")
		await anim_player.animation_finished  
		is_animating = false  

	current_open_popup = new_popup  # Track the open popup

# Function to close a popup with exit animation
func close_popup(popup: Control):
	if is_animating:
		return
	
	var anim_player = popup.get_node_or_null("AnimationInOut") as AnimationPlayer
	if anim_player:
		is_animating = true
		anim_player.play("TransitionOut")
		await anim_player.animation_finished  
		is_animating = false  
	
	popup.visible = false  
	current_open_popup = null  # Reset tracking

func _on_toggle_settings_button_pressed():
	toggle_popup(settings_popup)

func _on_toggle_inventory_button_pressed():
	toggle_popup(inventory_popup)

func _on_toggle_shop_button_pressed():
	toggle_popup(shop_popup)

# Connect this function to the exit button inside each popup
func _on_exit_button_pressed():
	if current_open_popup:
		close_popup(current_open_popup)
