class_name TumbangPresoPhase
extends Node2D

var new_coins : int = 0
var new_points : int = 0

signal add_phase_rewards(new_coins, new_points)

func broadcast_rewards(phase_coins : int, phase_points : int) -> void:
	new_coins = phase_coins
	new_points = phase_points
	emit_signal("add_phase_rewards")
