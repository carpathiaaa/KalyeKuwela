extends Control

@onready var level_label = $Container/LeftContainer/LevelLabel
@onready var coins_label = $Container/LeftContainer/CoinsLabel
@onready var timer_label = $Container/RightContainer/TimerLabel
@onready var score_label = $Container/RightContainer/ScoreLabel

@onready var label_timer = $LabelTimer # optional timer 
@onready var game_scene : BaseGame = get_parent().get_parent()

var remaining_seconds : float = 15 # Store elpased time in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_scene is not BaseGame:
		push_error("Invalid game scene (info overlay)")

func update_level_label(new_level : int) -> void:
	level_label.text = " Level " + str(new_level)

func update_coins_label(new_coins : int) -> void:
	coins_label.text = "    " + str(new_coins)

func update_score_label(new_score : int) ->void:
	score_label.text = str(new_score) + " "

func update_timer_label() -> void:
	timer_label.text = str(int(remaining_seconds)) + " "

func set_timer(seconds : float) -> void:
	label_timer.stop() 
	if seconds <= 0:
		push_error("Timer (seconds) must be greater than 0.")
	remaining_seconds = seconds
	label_timer.start(1) # update timer every seconds
	
func add_time(seconds : float) -> void:
	print("timer incremented")
	remaining_seconds += seconds

func timer_finished() -> void:
	print("timer finished")

func _on_label_timer_timeout() -> void:
	remaining_seconds -= 1
	update_timer_label()
	if remaining_seconds <= 0: # Stop timer if 
		label_timer.stop()
		timer_finished()
	else:
		label_timer.start(1)
	
