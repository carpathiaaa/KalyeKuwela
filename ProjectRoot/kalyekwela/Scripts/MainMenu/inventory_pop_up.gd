extends Control

@onready var items_container = $MarginItems/ItemsContainer
@onready var characters_button = $Category/CategoryContainer/CharactersButton
@onready var accessories_button = $Category/CategoryContainer/AccessoriesButton

var current_category = "character"  # Default to Characters

func _ready():
	populate_inventory()

func populate_inventory():
	# Clear previous items
	for child in items_container.get_children():
		child.queue_free()

	var items = []
	if current_category == "character":
		items = GlobalData.owned_characters
	elif current_category == "accessory":
		items = GlobalData.owned_accessories

	# Add owned items to the grid
	for item in items:
		var item_button = Button.new()
		item_button.text = item
		item_button.icon = load(get_item_icon_path(item, current_category))
		item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		item_button.connect("pressed", Callable(self, "equip_item").bind(item, current_category))
		items_container.add_child(item_button)

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
			"Carlo": "res://Assets/Art/CharacterIcons/Character_Carlo_Icon.png"
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
