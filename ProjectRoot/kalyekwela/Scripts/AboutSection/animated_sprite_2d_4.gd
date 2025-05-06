extends Node2D

@onready var sprite := $"."

var start_pos := Vector2(854, 447)
var top_slide := Vector2(733, 376)
var bottom_slide := Vector2(586, 458)

func _ready():
	sprite.position = start_pos
	simulate_slide()

func simulate_slide():
	move_to(top_slide, 1.0, "on_reach_top")

func on_reach_top():
	sprite.play("IdleSide")
	await get_tree().create_timer(0.4).timeout
	move_to(bottom_slide, 0.8, "on_reach_bottom")

func on_reach_bottom():
	sprite.play("IdleSide")
	await get_tree().create_timer(0.3).timeout
	move_to(start_pos, 1.2, "simulate_slide")

func move_to(target_pos: Vector2, duration: float, callback_name: String):
	var direction = target_pos.x - sprite.position.x
	sprite.flip_h = direction < 0
	sprite.play("WalkSide")

	var tween := create_tween()
	tween.tween_property(sprite, "position", target_pos, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, callback_name))
