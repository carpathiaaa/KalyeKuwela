extends BaseGame

@onready var main_timer = $main_timer

@onready var first_phase = load("res://Scenes/TumbangPreso/first_phase.tscn")
@onready var second_phase = load("res://Scenes/TumbangPreso/second_phase.tscn")

var first_phase_instance : Node = null
var second_phase_instance : Node = null

const first_phase_time : int = 15
const second_phase_time : int = 10

var level : int = 1

signal first_phase_ended 
signal second_phase_ended

var finished : bool = false



func _ready() -> void:
	# event sequence
	while not finished:
		start_first_phase()
		await first_phase_ended
		if not finished:
			start_second_phase()
			await second_phase_ended
		level += 1

func start_first_phase() -> void:
	print("Starting first phase")
	first_phase_instance = first_phase.instantiate()
	first_phase_instance.update_difficulty(level)
	add_child(first_phase_instance)

func end_first_phase() -> void:
	print("Ending first phase")
	first_phase_instance.queue_free()
	emit_signal("first_phase_ended")

func start_second_phase() -> void:
	print("Starting second phase")
	second_phase_instance = second_phase.instantiate()
	second_phase_instance.update_difficulty(level)
	add_child(second_phase_instance)

func end_second_phase() -> void:
	print("Ending second phase")
	emit_signal("second_phase_ended")
	second_phase_instance.queue_free()
