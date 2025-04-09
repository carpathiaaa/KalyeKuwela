extends FloatingEnemy

@onready var player = $"../player"

func _ready() -> void:
	target_player = player
	speed = 100
