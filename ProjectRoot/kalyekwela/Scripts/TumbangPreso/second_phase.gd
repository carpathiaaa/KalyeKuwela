extends Node2D

@onready var countdown_timer = $countdown_timer

const phase_time : int = 15

func _ready() -> void:
	countdown_timer.start(phase_time)
	await countdown_timer.timeout
	get_parent().end_second_phase()
