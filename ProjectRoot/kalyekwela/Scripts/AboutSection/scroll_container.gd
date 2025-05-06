extends ScrollContainer

var auto_scroll_speed := 100 # pixels per second
var is_touching := false
var last_touch_y := 0.0
var user_interrupted := false
var transitioning := false
var tween = null

func _ready():
	await get_tree().process_frame # Let layout settle
	scroll_vertical = 0 # Start at top
	
	# Hide the vertical scrollbar
	#get_v_scroll_bar().modulate.a = 0  # Set alpha to 0 (completely transparent)

func _process(delta):
	if transitioning:
		return
		
	if not is_touching and not user_interrupted:
		# Increase scroll value to move content upward
		var new_scroll = scroll_vertical + int(auto_scroll_speed * delta)
		var max_scroll = get_v_scroll_bar().max_value
		
		# Check if we've reached the end
		if new_scroll >= max_scroll - 5: # Small buffer to ensure we catch the end
			reset_scroll()
		else:
			scroll_vertical = new_scroll

# Direct reset function - no tween
func reset_scroll():
	scroll_vertical = 0

# Alternative with manual reset animation
func reset_scroll_animated():
	transitioning = true
	
	# Store current position
	var start_pos = scroll_vertical
	var start_time = Time.get_ticks_msec() / 1000.0
	var duration = 0.5 # Duration in seconds
	
	# Create our own animation loop instead of using tween
	while transitioning:
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed = current_time - start_time
		
		if elapsed >= duration:
			scroll_vertical = 0
			transitioning = false
			break
			
		# Calculate interpolated position (0 to 1 progress)
		var t = elapsed / duration
		var ease_t = 1.0 - pow(1.0 - t, 3) # Ease out cubic
		scroll_vertical = start_pos - (start_pos * ease_t)
		
		await get_tree().process_frame
	
	# Ensure we're fully reset
	scroll_vertical = 0

func _input(event):
	if transitioning:
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			last_touch_y = event.position.y
			user_interrupted = true
		else:
			is_touching = false
			await get_tree().create_timer(1.0).timeout
			user_interrupted = false
	elif event is InputEventScreenDrag and is_touching:
		var drag_amount = event.position.y - last_touch_y
		scroll_vertical -= int(drag_amount) # Keep drag direction intuitive
		last_touch_y = event.position.y
