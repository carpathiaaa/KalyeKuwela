extends BaseGame

@onready var main_timer = $main_timer

@onready var first_phase = load("res://Scenes/TumbangPreso/first_phase.tscn")
@onready var second_phase = load("res://Scenes/TumbangPreso/second_phase.tscn")
@onready var info_overlay = $user_interface/InfoOverlay

var first_phase_instance : Node = null
var second_phase_instance : Node = null

var first_phase_time : int = 7
var second_phase_time : int = 15
const countdown_time : int = 3

signal first_phase_ended 
signal second_phase_ended

var finished : bool = false

func _ready() -> void:
	# event sequence
	while not finished:
		start_first_phase()
		info_overlay.set_timer(first_phase_time + countdown_time)
		await first_phase_ended
		if not finished:
			info_overlay.set_timer(second_phase_time)
			start_second_phase()
			await second_phase_ended
		level += 1

func start_first_phase() -> void:
	print("Starting first phase")
	first_phase_instance = first_phase.instantiate()
	first_phase_instance.update_phase(level, first_phase_time, countdown_time)
	info_overlay.update_level_label(level)
	add_child(first_phase_instance)

func end_first_phase() -> void:
	print("Ending first phase")
	first_phase_instance.queue_free()
	emit_signal("first_phase_ended")

func start_second_phase() -> void:
	print("Starting second phase")
	second_phase_instance = second_phase.instantiate()
	secon d_phase_instance.update_phase(level, second_phase_time, countdown_time)
	add_child(second_phase_instance)

func end_second_phase() -> void:
	print("Ending second phase")
	emit_signal("second_phase_ended")
	second_phase_instance.queue_free()

func add_rewards(new_coins, new_exp) -> void:
	add_coins(new_coins)
	info_overlay.update_coins_label(coins)
	add_exp(new_exp)
	info_overlay.update_score_label(exp)
