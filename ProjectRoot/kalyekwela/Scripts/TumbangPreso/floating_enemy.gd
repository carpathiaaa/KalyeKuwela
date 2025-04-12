extends MovingEnemy

@onready var player = $"../player"
var new_speed : float = 100.0

func _ready() ->void:
	set_target(player, new_speed)

func _physics_process(delta: float) -> void:
	update_velocity(simple_float(), delta)
