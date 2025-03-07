extends Control

@onready var items_container = $MarginItems/ItemsContainer
@onready var characters_button = $Category/CategoryContainer/CharactersButton
@onready var accessories_button = $Category/CategoryContainer/AccessoriesButton
@onready var inventory_slot_template = $MarginItems/ItemsContainer/InventorySlot


var current_category = "character"  # Default to Characters

func _ready():
	populate_inventory()

func populate_inventory():
	if not inventory_slot_template:
		print("Error: Inventory slot template not found!")
		return

	# Remove previous items but keep the template
	for child in items_container.get_children():
		if child != inventory_slot_template:
			child.queue_free()

	# Get the owned items based on category
	var owned_items = []
	if current_category == "character":
		owned_items = GlobalData.owned_characters
	elif current_category == "accessory":
		owned_items = GlobalData.owned_accessories

	# Populate inventory
	for item in owned_items:
		var inventory_slot = inventory_slot_template.duplicate()
		inventory_slot.visible = true

		# Assign values
		var item_name_label = inventory_slot.get_node("MarginContainer/ItemName")
		var character_icon = inventory_slot.get_node("MarginContainer2/CharacterIcon")

		item_name_label.text = item
		# Load item icon
		var item_icon = load(get_item_icon_path(item, current_category))
		if item_icon:
			character_icon.texture = item_icon

		items_container.add_child(inventory_slot)


# 🎭 Equip selected character or accessory
func equip_item(item_name: String, item_type: String):
	if item_type == "character":
		GlobalData.equipped_character = item_name
	elif item_type == "accessory":
		GlobalData.equipped_accessory = item_name
	GlobalData.save_data()
	print(item_type.capitalize() + " equipped:", item_name)

# 🔍 Get icon path dynamically
func get_item_icon_path(name: String, item_type: String) -> String:
	var icons = {
		"character": {
			"Antonio": "res://Assets/Art/CharacterIcons/Character_Antonio_Icon.png",
			"Carlo": "res://Assets/Art/CharacterIcons/Character_Carlo_Icon.png",
			"Juan": "res://Assets/Art/CharacterIcons/Character_Juan_Icon.png",
			"Maria": "res://Assets/Art/CharacterIcons/Character_Maria_Icon.png",
			"Reyna": "res://Assets/Art/CharacterIcons/Character_Reyna_Icon.png",
			"Tala": "res://Assets/Art/CharacterIcons/Character_Tala_Icon.png",
		},
		"accessory": {
			"Cool Hat": "res://Assets/Art/CharacterIcons/Character_Reyna_Icon.png",
			"Glasses": "res://Assets/Art/CharacterIcons/Character_Tala_Icon.png"
		}
	}
	return icons.get(item_type, {}).get(name, "res://Assets/Art/AccessoriesIcons/default_icon.png")

# 🔄 Change category
func _on_characters_button_pressed():
	current_category = "character"
	populate_inventory()

func _on_accessories_button_pressed():
	current_category = "accessory"
	populate_inventory()
