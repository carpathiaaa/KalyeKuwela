class_name LoopFloatEnemy
extends BaseEnemy

@onready var enemy_sprite = $Sprite2D
var min_y = -190
var max_y = 130

var direction : Vector2 = Vector2.ZERO
var moving_up : bool = false
var base_speed : float = 2
var speed : float = 2

func set_target(player, level : int) -> void:
	speed = base_speed + (0.15 * level)

func _physics_process(delta: float) -> void:
	if self.position.y >= max_y:
		enemy_sprite.play("WalkBack")
		moving_up = false
	elif self.position.y <= min_y:
		enemy_sprite.play("WalkFront")
		moving_up = true
	if moving_up:
		self.position.y += speed
	else:
		self.position.y -= speed
	move_and_slide()
