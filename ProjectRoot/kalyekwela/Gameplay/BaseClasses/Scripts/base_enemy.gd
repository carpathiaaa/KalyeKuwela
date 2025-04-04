# base_enemy.gd
extends CharacterBody2D
class_name BaseEnemy

signal game_over

func _ready() -> void:
	print("Enemy spawned")
	pass

func touch_player() -> void:
	print("enemy touched player")
	emit_signal("game_over")
