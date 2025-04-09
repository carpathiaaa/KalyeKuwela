extends Node2D

@onready var countdown_timer = $countdown_timer
@onready var floating_enemy = $"res://Gameplay/BaseClasses/Scenes/floating_enemy.tscn"
@onready var player = $player

const phase_time : int = 15

func _ready() -> void:
	countdown_timer.start(phase_time)
#	spawn_enemy()
	await countdown_timer.timeout
	get_parent().end_second_phase()

#func spawn_enemy() -> void:
#	var new_floating_enemy = floating_enemy.instantiate()
#	new_floating_enemy.target_player = player
#	new_floating_enemy.speed = 100
#	add_child(new_floating_enemy)
