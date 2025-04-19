extends Control

@onready var audio_slider = $SettingsFunctionContainer/SettingsContents/AudioSlider
@onready var brightness_slider = $SettingsFunctionContainer/SettingsContents/BrightnessSlider
@onready var mute_button = $SettingsFunctionContainer/SettingsButtonsCanvas/SettingsButtonsContainer/MuteToggle
@onready var reset_button = $SettingsFunctionContainer/ResetDataMargin/ResetGameDataButton
@onready var reset_confirmation_popup = $SettingsFunctionContainer/ConfirmationMargin
@onready var confirm_reset_button = $SettingsFunctionContainer/ConfirmationMargin/VBoxContainer/HBoxContainer/YesButton
@onready var cancel_reset_button = $SettingsFunctionContainer/ConfirmationMargin/VBoxContainer/HBoxContainer/NoButton
@onready var brightness_overlay = $"../ColorRect"

@onready var click_sound = $"../ClickSound"
@onready var click_sound_2 = $"../ClickSound2"


var previous_volume_db: float = 0.0  
var is_muted: bool = false  

func _ready() -> void:
	# Initialize Audio Slider
	var current_db = AudioServer.get_bus_volume_db(0)
	audio_slider.value = db_to_linear(current_db)
	previous_volume_db = current_db  

	# Initialize Brightness Slider to Maximum (1.0)
	brightness_slider.value = 1.0  
	_update_brightness()

func _on_audio_slider_value_changed(value: float) -> void:
	if is_muted and value > 0.0:
		is_muted = false
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
		previous_volume_db = linear_to_db(value)
		mute_button.button_pressed = false  
	else:
		var db_value = linear_to_db(value)
		AudioServer.set_bus_volume_db(0, db_value)
		previous_volume_db = db_value  

func _on_brightness_slider_value_changed(value: float) -> void:
	_update_brightness()

func _on_mute_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_click_sound_2()
		#await click_sound_2.finished
		previous_volume_db = AudioServer.get_bus_volume_db(0)  
		AudioServer.set_bus_volume_db(0, -80)  
		audio_slider.value = 0.0  
		is_muted = true
	else:
		AudioServer.set_bus_volume_db(0, previous_volume_db)
		audio_slider.value = db_to_linear(previous_volume_db)  
		is_muted = false

func _on_brightness_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_click_sound_2()
		brightness_slider.value = 0.0  
	else:
		brightness_slider.value = 1.0  
	_update_brightness()

func _update_brightness() -> void:
	var brightness = clamp(brightness_slider.value, 0.0, 1.0)
	var alpha_value = 0.5 - (brightness * 0.5)  
	brightness_overlay.color.a = alpha_value

func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()

# ---- RESET DATA FUNCTIONS ----
func _on_reset_game_data_button_pressed() -> void:
	play_click_sound()
	reset_confirmation_popup.visible = true  

func _on_yes_button_pressed() -> void:
	play_click_sound()
	GlobalData.reset_data()  # Clears all saved data
	reset_confirmation_popup.visible = false  
	print("Game data reset successfully!")
	$"../CharacterSelect".refresh_avatar()
	# Restart the game by reloading the current scene
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")

func _on_no_button_pressed() -> void:
	play_click_sound()
	reset_confirmation_popup.visible = false  
