extends Control

@onready var level_label = $Container/LeftContainer/LevelLabel
@onready var coins_label = $Container/LeftContainer/CoinsLabel
@onready var timer_label = $Container/RightContainer/TimerLabel
@onready var score_label = $Container/RightContainer/ScoreLabel
@onready var hearts_label = $Container/RightContainer/HeartsLabel

@onready var label_timer = $LabelTimer # optional timer 

var remaining_seconds : float = 30 # Store elpased time in seconds


func update_level_label(new_level : int) -> void:
	print("updated level label: " + str(new_level))
	level_label.text = " Level " + format_with_commas(new_level)

func update_coins_label(new_coins : int) -> void:
	print("updated coins label: " + str(new_coins))
	coins_label.text = "           " + format_with_commas(new_coins)

func update_score_label(new_score : int) ->void:
	print("updated score label: " + str(new_score))
	score_label.text = format_with_commas(new_score) + " "

func update_timer_label() -> void:
	var total_seconds := int(remaining_seconds)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]
	print("Updated timer label: ", timer_label.text)

func update_hearts_label(new_health : int) ->void:
	print("updated level label: " + str(new_health))
	hearts_label.update_hearts(new_health)

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

func hide_timer_label() -> void:
	timer_label.hide()

func hide_score_label() -> void:
	score_label.hide()

func _on_label_timer_timeout() -> void:
	remaining_seconds -= 1
	update_timer_label()
	if remaining_seconds <= 0: # Stop timer if 
		label_timer.stop()
		timer_finished()
	else:
		label_timer.start(1)
	
func format_with_commas(number: int) -> String:
	var str_num = str(number)
	var result = ""
	var length = str_num.length()
	if number > 0:
		for i in range(length):
			result += str_num[i]
			# Add commas every 3 digits (except the last set)
			if (length - i - 1) % 3 == 0 and i != length - 1:
				result += ","
	else:
		result += "-"
		for i in range(1, length):
			result += str_num[i]
			# Add commas every 3 digits (except the last set)
			if (length - i - 1) % 3 == 0 and i != length - 1:
				result += ","
	return result
