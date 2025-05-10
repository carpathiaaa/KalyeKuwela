extends BaseGame

@onready var main_timer = $main_timer

@onready var first_phase = preload("res://Scenes/TumbangPreso/first_phase.tscn")
@onready var second_phase = preload("res://Scenes/TumbangPreso/second_phase.tscn")
@onready var win_screen = preload("res://Scenes/TumbangPreso/win_screen.tscn")
@onready var info_overlay = $user_interface/InfoOverlay
@onready var hearts_label = $user_interface/InfoOverlay/Container/RightContainer/HeartsLabel
@onready var tutorial_menu = $user_interface/Tutorial
@onready var joystick = $"user_interface/Virtual Joystick"

var location_string : String = "res://Scenes/TumbangPreso/main.tscn"

var first_phase_instance : Node = null
var second_phase_instance : Node = null

var threshold_score : int = 30
var current_score : int  = 0

var first_phase_time : int = 7
var second_phase_time : int = 30
const countdown_time : int = 3

signal first_phase_ended 
signal second_phase_ended
var pass_to_next : bool = false

func _ready() -> void:
	hearts_label.hide()
	set_tutorial()
	current_game = location_string
	# Start event sequence
	start_events()

func start_events() -> void:
	print("Starting event sequence")
	start_first_phase()
	info_overlay.set_timer(first_phase_time + countdown_time)
	await first_phase_ended
	if (current_score >= threshold_score):
		player_wins()
	elif(current_score <= -500):
		player_loses()
	else:
		info_overlay.set_timer(second_phase_time)
		start_second_phase()
	await second_phase_ended
	if pass_to_next:
		next_level()
	else:
		player_loses()

func set_tutorial() -> void:
	var tutorial_text = "[outline_color=#103947,outline_thickness=6][color=#1B4D3E]1. Time Your Throw![/color][/outline_color]
Wait for the bar to reach the green zone, then click Throw to launch your slipper. The better the timing, the better the shot!

[outline_color=#103947,outline_thickness=3][color=#D65F2F]2. Retrieve Your Slipper![/color][/outline_color]
Run and collect your slipper after throwing — but don't get too close to the preso guarding the can.

[outline_color=#103947,outline_thickness=3][color=#3A7CA5]3. Dodge and Survive![/color][/outline_color]
Avoid getting tagged while retrieving your slipper. Make it back to safety and prepare for your next throw!

 If your score is high enough, you might get a surprise! 🎉
"
	tutorial_menu.change_tutorial("Tumbang Preso", tutorial_text)


func player_wins() -> void:
	print("Player wins")
	add_rewards(coins, exp)
	set_end_delay(3.5)
	end_sequence()
	var win_screen_instance = win_screen.instantiate()
	add_child(win_screen_instance)


func player_loses() -> void:
	print("Player loses")
	add_rewards(coins, exp)
	end_sequence()

func next_level() -> void:
	print("Game not finished")
	threshold_score += 5
	level += 1
	start_events() # restart event sequence

func start_first_phase() -> void:
	print("Starting first phase")
	joystick.hide()
	first_phase_instance = first_phase.instantiate()
	first_phase_instance.update_phase(level, first_phase_time, countdown_time)
	first_phase_instance.add_phase_rewards.connect(add_rewards, CONNECT_ONE_SHOT)
	info_overlay.update_level_label(level)
	add_child(first_phase_instance)

func end_first_phase() -> void:
	print("Ending first phase")
	first_phase_instance.queue_free()
	emit_signal("first_phase_ended")

func start_second_phase() -> void:
	print("Starting second phase")
	joystick.show()
	second_phase_instance = second_phase.instantiate()
	second_phase_instance.update_phase(level, second_phase_time, countdown_time)
	second_phase_instance.add_phase_rewards.connect(add_rewards, CONNECT_ONE_SHOT)
	second_phase_instance.sandal_touched.connect(success_second_phase)
	add_child(second_phase_instance)

func success_second_phase() -> void:
	print("Ending second phase")
	second_phase_instance.queue_free() 
	pass_to_next = true
	emit_signal("second_phase_ended")

func end_second_phase() -> void:
	print("Ending second phase")
	second_phase_instance.queue_free() 
	pass_to_next = false
	emit_signal("second_phase_ended")

func add_rewards(new_coins : int, new_exp : int) -> void:
	print("rewards received")
	add_coins(new_coins)
	info_overlay.update_coins_label(coins)
	add_exp(new_exp)
	update_score(new_exp)

func update_score(new_score: int) -> void:
	current_score += new_score
	info_overlay.update_score_label(current_score)
