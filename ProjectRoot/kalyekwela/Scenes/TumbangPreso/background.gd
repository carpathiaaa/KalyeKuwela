extends ParallaxBackground

@export var scroll_speed : float = 100  # Adjust speed

func _process(delta):
	self.scroll_offset.x -= scroll_speed * delta
