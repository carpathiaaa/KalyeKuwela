extends Node2D

@onready var start_timer = $StartTimer
@onready var game_timer = $GameTimer
@onready var countdown_label = $UI/CountdownLabel
@onready var game_over_label = $UI/GameOverLabel  # Label for game over message
@onready var game_timer_label = $UI/GameTimerLabel  # Label for game countdown
@onready var player = $Player
@onready var npcs = $NPCs.get_children()

var first_chaser_assigned = false  # Prevents multiple assignments
var game_has_ended = false  # Prevents duplicate game-over calls

func _ready():
	# Ensure countdown label is centered
	# Center the label using viewport size
	var screen_size = get_viewport_rect().size
	countdown_label.position = screen_size / 2 - countdown_label.size / 2

	countdown_label.visible = true
	game_over_label.visible = false
	game_timer_label.visible = false  # Hide timer at first

	await countdown_sequence()
	
	start_timer.start()
	game_timer.wait_time = 90  # 1 minute 30 seconds

	# Connect timers
	start_timer.timeout.connect(_on_start_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)

func _process(delta):
	# Update game timer label
	if game_timer.time_left > 0 and game_timer_label.visible:
		update_game_timer_label()

	# End game if all players become chasers before time runs out
	if not game_has_ended and all_are_chasers():
		game_over("Game Over. Chasers Won!")

func countdown_sequence():
	countdown_label.text = "3"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "2"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "1"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "GO!"
	await get_tree().create_timer(1).timeout
	countdown_label.visible = false  # Hide countdown label after "GO!"

func _on_start_timer_timeout():
	if not first_chaser_assigned:
		assign_chaser()
		game_timer.start()
		game_timer_label.visible = true  # Show game timer when game starts
		first_chaser_assigned = true

func assign_chaser():
	var all_entities = [player] + npcs
	if all_entities.is_empty():
		print("No entities found to assign as chaser!")
		return
	
	# Select a random entity to become the first chaser
	var chaser = all_entities[randi() % all_entities.size()]

	# Ensure we're not selecting an already-chosen chaser
	for i in range(10):
		if not chaser.is_chaser:
			break
		chaser = all_entities[randi() % all_entities.size()]

	if chaser.is_chaser:
		print("Failed to assign a new chaser after multiple attempts!")
		return

	chaser.become_chaser()
	print("First chaser assigned:", chaser.name)

func update_game_timer_label():
	var time_left = int(game_timer.time_left)
	var minutes = time_left / 60
	var seconds = time_left % 60
	game_timer_label.text = "Time: %02d:%02d" % [minutes, seconds]  # Format MM:SS

func _on_game_timer_timeout():
	if count_runners() > 0:
		game_over("Game Over. Runners Won!")  # Runners survived
	else:
		game_over("Game Over. Chasers Won!")  # All got tagged last second

func all_are_chasers() -> bool:
	# Check if player and all NPCs are chasers
	if not player.is_chaser:
		return false

	for npc in npcs:
		if not npc.is_chaser:
			return false

	return true  # All entities are chasers

func count_runners() -> int:
	var runner_count = 0
	if not player.is_chaser:
		runner_count += 1

	for npc in npcs:
		if not npc.is_chaser:
			runner_count += 1

	return runner_count

func game_over(message):
	if game_has_ended:
		return  # Prevent multiple game-over calls

	game_has_ended = true
	game_over_label.visible = true  # Show game over label
	game_over_label.text = message  # Set message
	game_timer_label.visible = false  # Hide timer when game ends
	print(message)  # Debug print

	# Wait a few seconds before quitting
	await get_tree().create_timer(3).timeout
	get_tree().quit()
