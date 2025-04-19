extends Node
const SAVE_PATH = "user://save_data.json"

var coins = 0
var xp = 0
var level = 1
var base_xp = 100
var growth_rate = 1.5
var max_level = 10

# Shop Data
var owned_characters = []  # List of character IDs owned
var owned_accessories = []  # List of accessory IDs owned
var equipped_character = ""  # Currently equipped character
var equipped_accessory = ""  # Currently equipped accessory


var PlayerSelect = 0

var previous_game : String

func get_xp_required(level) -> int:
	return int(base_xp * pow(level, growth_rate))

func add_rewards(coin_reward, xp_reward):
	coins += coin_reward
	xp += xp_reward
	check_level_up()

	var main_menu = get_node_or_null("/root/MainMenu")
	if main_menu:
		main_menu.update_ui()

	save_data()

func check_level_up():
	while level < max_level and xp >= get_xp_required(level):
		xp -= get_xp_required(level)
		level += 1
		print("Leveled up! Now Level:", level)

	# Ensure XP does not go negative at max level
	if level >= max_level:
		xp = min(xp, get_xp_required(max_level))

	var main_menu = get_node_or_null("/root/MainMenu")
	if main_menu:
		main_menu.update_ui()

# 🛒 Purchase an item (Character or Accessory)
func purchase_item(item_id: String, item_type: String, cost: int) -> bool:
	if coins < cost:
		return false  # Not enough coins

	coins -= cost

	match item_type:
		"character":
			if item_id not in owned_characters:
				owned_characters.append(item_id)
		"accessory":
			if item_id not in owned_accessories:
				owned_accessories.append(item_id)

	save_data()
	return true  # Purchase successful

# 💾 Save game data
func save_data():
	var data = {
		"coins": coins,
		"xp": xp,
		"level": level,
		"owned_characters": owned_characters,
		"owned_accessories": owned_accessories,
		"equipped_character": equipped_character,
		"equipped_accessory": equipped_accessory
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved:", data)

# 📂 Load game data with error handling
func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		file.close()

		if content.is_empty():
			print("⚠️ Save file exists but is empty. Resetting data.")
			reset_data()
			return

		var data = JSON.parse_string(content)
		
		if data is Dictionary:
			# ✅ Use get() with defaults to prevent null values
			coins = data.get("coins", 0)
			xp = data.get("xp", 0)
			level = data.get("level", 1)
			owned_characters = data.get("owned_characters", [])
			owned_accessories = data.get("owned_accessories", [])
			equipped_character = data.get("equipped_character", "")
			equipped_accessory = data.get("equipped_accessory", "")

			check_level_up()
			print("✅ Game loaded successfully:", data)
		else:
			print("❌ Error: Invalid save data. Resetting to defaults.")
			reset_data()
	else:
		print("📂 No save file found. Initializing new save.")
		reset_data()


# Reset data if save file is corrupted or missing
func reset_data():
	coins = 0
	xp = 0
	level = 1
	owned_characters = []
	owned_accessories = []
	equipped_character = ""
	equipped_accessory = ""
	save_data()
	
