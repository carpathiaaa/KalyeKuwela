extends Node2D

@onready var start_timer = $StartTimer
@onready var game_timer = $GameTimer
@onready var countdown_label = $UI/CountdownLabel
@onready var game_over_label = $UI/GameOverLabel  # Label for game over message
@onready var game_timer_label = $UI/GameTimerLabel  # Label for game countdown
@onready var player = $Player
@onready var npcs = $NPCs.get_children()
@onready var game_over_music = $GameOverMusic  # 🎵 Game Over Music

@onready var pause_button = $UI/PauseButton
@onready var pause_menu = $UI/PauseMenu
@onready var how_to_play_button = $UI/HowToPlayButton
@onready var how_to_play_popup = $UI/HowToPlayMargin

@onready var pause_sound = $PauseSound
@onready var click_sound = $ClickSound
@onready var click_sound_2 = $ClickSound2

@export var settings_popup: MarginContainer

@onready var hearts_container = $UI/HeartsContainer

var current_game : String = "res://Scenes/BenteUno/main.tscn"

var paused = false
var first_chaser_assigned = false  # Prevents multiple assignments
var game_has_ended = false  # Prevents duplicate game-over calls

func _ready():
	pause_menu.hide()
	pause_button.pressed.connect(pauseMenu)

	hearts_container.setMaxHearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.health_changed.connect(hearts_container.update_hearts)

	paused = false  # Reset pause state
	first_chaser_assigned = false  # Ensure first chaser is re-selected
	game_has_ended = false  # Allow game to end properly

	game_timer.stop()  # Ensure timers reset
	start_timer.stop()
	
	game_timer.wait_time = 90  # Reset game time
	game_timer_label.text = "Time: 01:30"  # Reset label
	countdown_label.text = "3"  # Reset countdown

	pause_menu.hide()  # Ensure pause menu is hidden
	Engine.time_scale = 1  # Unpause the game

	# Reset player and NPC states
	player.is_chaser = false  # Ensure player is a runner at the start
	for npc in npcs:
		npc.is_chaser = false  # Reset NPC chasers

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
	if Input.is_action_just_pressed('pause'):
		play_pause_sound()
		pauseMenu()
	# Update game timer label
	if game_timer.time_left > 0 and game_timer_label.visible:
		update_game_timer_label()

	# End game if all players become chasers before time runs out
	if not game_has_ended and all_are_chasers():
		game_over("Game Over. Chasers Won!")
		pause_button.visible = false
		how_to_play_button.visible = false

func play_pause_sound():
	if pause_sound:
		pause_sound.play()
		
func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()

func howToPlay():
	play_pause_sound()
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused

func pauseMenu():
	play_pause_sound()
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
	
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
		pause_button.visible = false
		how_to_play_button.visible = false
		game_over("Game Over. Runners Won!")  # Runners survived
	else:
		pause_button.visible = false
		how_to_play_button.visible = false
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
	
	# 🎵 Stop existing background/chase music
	if player.background_music and player.background_music.playing:
		player.background_music.stop()
	if player.chase_sfx and player.chase_sfx.playing:
		player.chase_sfx.stop()

	# 🎵 Play Game Over Music
	game_over_music.play()

	# Give rewards based on outcome
	if message == "Game Over. Chasers Won!":
		GlobalData.add_rewards(10, 10)
	elif message == "Game Over. Runners Won!":
		if player.is_chaser:
			GlobalData.add_rewards(10, 10)
		else:
			GlobalData.add_rewards(50, 50)

	print("Coins:", GlobalData.coins, "XP:", GlobalData.xp)  # Debugging
	
	# Wait a few seconds before quitting
	await get_tree().create_timer(3).timeout
	GlobalData.previous_game = current_game
	CompactTransition.load_scene("res://Scenes/BaseScenes/UI/score_summary.tscn")

func _on_resume_button_pressed() -> void:
	print("Resuming game")
	pauseMenu()

func _on_quit_button_pressed() -> void:
	play_click_sound_2()
	await click_sound_2.finished
	print("Quitting game")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")

func _exit_tree():
	Engine.time_scale = 1  # Ensure time resumes properly

func toggle_popup(SettingsPopUp : MarginContainer):
	SettingsPopUp.visible = !SettingsPopUp.visible

func _on_settings_button_pressed() -> void:
	play_click_sound()
	toggle_popup(settings_popup)

func _on_reset_button_pressed() -> void:
	play_click_sound_2()
	await click_sound_2.finished
	GlobalData.temporary_reset_mode = true  # Prevent saving on reset
	get_tree().reload_current_scene()
	
func toggle_how_to_play():
	play_pause_sound()
	
	if how_to_play_popup.visible:
		how_to_play_popup.visible = false
		Engine.time_scale = 1
		paused = false
	else:
		how_to_play_popup.visible = true
		Engine.time_scale = 0
		paused = true

func _on_how_to_play_button_pressed() -> void:
	toggle_how_to_play()
