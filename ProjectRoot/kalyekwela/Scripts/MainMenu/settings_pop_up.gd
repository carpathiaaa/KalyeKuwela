extends Control

@onready var audio_slider = $SettingsFunctionContainer/SettingsContents/AudioSlider
@onready var brightness_slider = $SettingsFunctionContainer/SettingsContents/BrightnessSlider
@onready var mute_button = $SettingsFunctionContainer/SettingsButtonsCanvas/SettingsButtonsContainer/MuteToggle  # Reference to the mute button
@export var brightness_overlay: ColorRect

var previous_volume_db: float = 0.0  # Stores last volume before mute
var is_muted: bool = false  # Tracks mute state

func _ready() -> void:
	# Initialize Audio Slider
	var current_db = AudioServer.get_bus_volume_db(0)
	audio_slider.value = db_to_linear(current_db)
	previous_volume_db = current_db  # Store initial volume
	
	# Initialize Brightness Slider to Maximum (1.0)
	brightness_slider.value = 1.0  
	_update_brightness()

func _on_audio_slider_value_changed(value: float) -> void:
	if is_muted and value > 0.0:
		# If slider is moved while muted, unmute and restore previous volume
		is_muted = false
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
		previous_volume_db = linear_to_db(value)  # Store new volume
		mute_button.button_pressed = false  # Update UI to show unmuted state
	else:
		# Normal volume adjustment
		var db_value = linear_to_db(value)
		AudioServer.set_bus_volume_db(0, db_value)
		previous_volume_db = db_value  # Save new volume when adjusted

func _on_brightness_slider_value_changed(value: float) -> void:
	_update_brightness()

func _on_mute_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Save current volume and mute
		previous_volume_db = AudioServer.get_bus_volume_db(0)  
		AudioServer.set_bus_volume_db(0, -80)  # Mute sound
		audio_slider.value = 0.0  # Move slider to 0
		is_muted = true
	else:
		# Restore previous volume
		AudioServer.set_bus_volume_db(0, previous_volume_db)
		audio_slider.value = db_to_linear(previous_volume_db)  # Restore slider
		is_muted = false

func _on_brightness_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		brightness_slider.value = 0.0  # Set to minimum brightness
	else:
		brightness_slider.value = 1.0  # Restore full brightness
	_update_brightness()

func _update_brightness() -> void:
	# Ensure brightness value stays within [0, 1.0]
	var brightness = clamp(brightness_slider.value, 0.0, 1.0)
	
	# Map brightness from range [0, 1.0] to alpha range [0.5 (dim), 0.0 (fully bright)]
	var alpha_value = 0.5 - (brightness * 0.5)  # 0.5 (darkest) → 0 (brightest)
	
	brightness_overlay.color.a = alpha_value
