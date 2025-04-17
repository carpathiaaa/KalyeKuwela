class_name LoopFloatEnemy
extends BaseEnemy

@onready var animation = $AnimationPlayer

var min_y = -190
var max_y = 210

var moving_up : bool = false

func _physics_process(delta: float) -> void:
	if self.position.y >= max_y:
		moving_up = false
	elif self.position.y <= min_y:
		moving_up = true
	if moving_up:
		self.position.y += log(PI)
	else:
		self.position.y -= log(PI)
