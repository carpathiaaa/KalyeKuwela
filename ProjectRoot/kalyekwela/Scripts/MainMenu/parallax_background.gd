extends ParallaxBackground

@export var scroll_speed : float = 40  # Adjust speed

func _process(delta):
	scroll_offset.x -= scroll_speed * delta
