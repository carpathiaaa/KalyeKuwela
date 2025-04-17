extends MovingEnemy


var new_speed : float = 100.0

var movement_pattern : Vector2 = Vector2.ZERO

func _ready() ->void:
	print("Enemy spawned at " + str(self.position))

func set_movement_pattern(new_movement_pattern : Vector2) -> void:
	print("Updating movement pattern")
	movement_pattern = new_movement_pattern

func _physics_process(delta: float) -> void:
	update_velocity(movement_pattern, delta)
