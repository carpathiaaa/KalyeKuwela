extends ParallaxBackground

@export var scroll_speed = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.scroll_offset.x += delta * scroll_speed
