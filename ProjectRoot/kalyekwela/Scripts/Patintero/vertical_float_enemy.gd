class_name VerticalFloatEnemy
extends MovingEnemy

func _physics_process(delta: float) -> void:
	update_velocity(simple_float(), delta)
