extends BaseEnemy
class_name TrackingEnemy

@export var target_player: Node
@export var speed: float = 100 # Default speed value
var current_velocity = Vector2.ZERO # Default velocity if target player is null

func _ready() -> void:
	super._ready() # Call the constructor method of BaseEnemy (parent) class

func configure(new_target: Node, new_speed: float) -> void:
	target_player = new_target # Assign target node after instantiation 
	speed = new_speed # Assign speed

func _physics_process(delta: float) -> void:
	if target_player: # execute if target player exists
		var direction = (target_player.position - position).normalized() # Track target relative to current position
		current_velocity = direction * speed # move towards the target
	else:
		current_velocity = Vector2.ZERO # no target detected -> remain stationary
	velocity = current_velocity  # float towards the target
	move_and_slide()
