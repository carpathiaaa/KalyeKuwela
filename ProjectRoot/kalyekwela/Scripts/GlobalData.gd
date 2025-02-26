extends Node
const SAVE_PATH = "user://save_data.json"

var coins = 0
var xp = 0
var level = 1
var base_xp = 100  # XP needed for level 1
var growth_rate = 1.5  # Adjust for difficulty
var max_level = 10

func get_xp_required(level) -> int:
	return int(base_xp * pow(level, growth_rate))  # Formula for required XP

func add_rewards(coin_reward, xp_reward):
	coins += coin_reward
	xp += xp_reward
	check_level_up()

	# Ensure UI updates when XP changes
	var main_menu = get_node_or_null("/root/MainMenu")
	if main_menu:
		main_menu.update_ui()

	save_data()  # Save automatically after gaining XP

func check_level_up():
	while level < max_level and xp >= get_xp_required(level):
		xp -= get_xp_required(level)  # Carry over excess XP
		level += 1
		print("Leveled up! Now Level:", level)
	
	# Ensure XP bar updates
	var main_menu = get_node_or_null("/root/MainMenu")
	if main_menu:
		main_menu.update_ui()

func save_data():
	var data = {
		"coins": coins,
		"xp": xp,
		"level": level  # Ensure level is saved
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved:", data)  # Debugging log

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data:
			coins = data.get("coins", 0)
			xp = data.get("xp", 0)
			level = data.get("level", 1)  # Load level
			check_level_up()  # Ensure XP carries over correctly
			print("Game loaded:", data)  # Debugging log
		else:
			print("Error loading save data.")
	else:
		print("No save file found.")
