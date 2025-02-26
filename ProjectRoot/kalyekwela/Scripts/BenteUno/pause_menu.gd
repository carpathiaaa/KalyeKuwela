#extends Control
#
#@onready var pause_button = %PauseButton
#@onready var resume_button = %ResumeButton
#@onready var quit_button = %QuitButton
#@onready var pause_menu = self  # Reference to the PauseMenu node
#
#func _ready():
	#pause_menu.visible = false  # Hide the menu at the start
	#
	## Connect buttons
	##pause_button.pressed.connect(_on_pause_button_pressed)
	#resume_button.pressed.connect(_on_resume_button_pressed)
	#quit_button.pressed.connect(_on_quit_button_pressed)
#
#func _on_pause_button_pressed():
	#get_tree().paused = true  # Pause the game
	#pause_menu.visible = true  # Show the pause menu
#
#func _on_resume_button_pressed():
	#get_tree().paused = false  # Resume the game
	#pause_menu.visible = false  # Hide the pause menu
#
#func _on_quit_button_pressed():
	#get_tree().paused = false  # Ensure game is unpaused before quitting
	#get_tree().change_scene_to_file("res://path/to/MainMenu.tscn")  # Adjust path to main menu
