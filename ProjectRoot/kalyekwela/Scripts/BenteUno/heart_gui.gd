extends Panel

@onready var heart_sprite = $Heart

func _ready():
	pass
	
func _process(delta):
	pass
	
func update(whole: bool):
	if whole: heart_sprite.frame = 0
	else: heart_sprite.frame = 1
		
