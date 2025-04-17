class_name RamdomFloatEnemy
extends MovingEnemy

var accumulated_time := 0.0

func _physics_process(delta: float):
	update_velocity(random_vertical_float(), delta)
