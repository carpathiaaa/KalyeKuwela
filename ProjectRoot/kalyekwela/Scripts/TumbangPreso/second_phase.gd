extends Node2D

@onready var countdown_timer = $countdown_timer
@onready var floating_enemy = $enemy_body
@onready var player = $player
@onready var game_scene : = get_parent()

var phase_time : int = 15

var difficulty : int = 1 # Default difficulty

func _ready() -> void:
	print("started")
	countdown_timer.start(phase_time)
	await countdown_timer.timeout
	game_scene.end_second_phase()

func update_phase(level : int, new_phase_time :int, countdown_time :int) -> void:
	print("Updated second phase difficulty : " + str(level))
	difficulty = level
	print("Updated second phase timer : " + str(new_phase_time))
	phase_time = new_phase_time

func _on_player_touched_enemy() -> void:
	print("touched ")
	get_parent().finished = true
	game_scene.end_game()
