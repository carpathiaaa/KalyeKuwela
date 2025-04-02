extends Node2D

@onready var main_player = $"../player"
@onready var body = $CharacterBody2D

func _physics_process(delta: float) -> void:
	body.velocity = Vector2(main_player.position)
