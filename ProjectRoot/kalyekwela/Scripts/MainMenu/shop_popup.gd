extends Control

@onready var items_container = $MarginItems/ItemsContainer
@onready var purchase_popup = $PurchasePopUp
@onready var item_name_label = $PurchasePopUp/ItemLabelPriceMargin/VBoxContainer/ItemName
@onready var item_price_label = $PurchasePopUp/ItemLabelPriceMargin/VBoxContainer/ItemPrice
@onready var item_icon = $PurchasePopUp/IconMargin/ItemIcon
@onready var characters_button = $Category/CategoryContainer/CharactersButton
@onready var accessories_button = $Category/CategoryContainer/AccessoriesButton
@onready var confirm_button = $PurchasePopUp/ConfimationActionMargin/ConfirmationContainer/ConfirmButton

var characters = [
	{"name": "Antonio", "price": 100, "icon": preload('res://Assets/Art/CharacterIcons/Character_Antonio_Icon.png')},
	{"name": "Carlo", "price": 200, "icon": preload("res://Assets/Art/CharacterIcons/Character_Carlo_Icon.png")},
]

var accessories = [
	{"name": "Cool Hat", "price": 50, "icon": preload("res://Assets/Art/CharacterIcons/Character_Reyna_Icon.png")},
	{"name": "Glasses", "price": 75, "icon": preload("res://Assets/Art/CharacterIcons/Character_Tala_Icon.png")},
]

var current_category = characters  # Default to Characters
var selected_item = null  # Stores selected item for purchase

func _ready():
	populate_shop()  # Load default category
	#confirm_button.pressed.connect(_on_confirm_button_pressed)  # Connect once

func populate_shop():
	# Remove all existing items
	for child in items_container.get_children():
		child.queue_free()

	# Add new items from the current category
	for item in current_category:
		var item_button = Button.new()
		item_button.text = item["name"]
		item_button.icon = item["icon"]
		item_button.connect("pressed", Callable(self, "_on_item_selected").bind(item))
		items_container.add_child(item_button)

func _on_item_selected(item):
	if not item:
		print("Error: No item data received!")
		return

	selected_item = item
	item_name_label.text = item["name"]
	item_price_label.text = "Price: " + str(item["price"])
	item_icon.texture = item["icon"]
	purchase_popup.visible = true  # Show popup

func _on_confirm_button_pressed():
	if not selected_item:  # Prevents errors if no item is selected
		print("No item selected!")
		return

	# Prevent duplicate purchases
	if selected_item["name"] in GlobalData.owned_characters or selected_item["name"] in GlobalData.owned_accessories:
		print("Item already owned!")
		return

	if GlobalData.coins >= selected_item["price"]:
		GlobalData.coins -= selected_item["price"]

		if current_category == characters:
			GlobalData.owned_characters.append(selected_item["name"])
		else:
			GlobalData.owned_accessories.append(selected_item["name"])

		GlobalData.save_data()
		purchase_popup.visible = false  # Close popup
	else:
		print("Not enough coins!")

func _on_cancel_button_pressed():
	purchase_popup.visible = false  # Close without buying

func _on_characters_button_pressed():
	current_category = characters
	populate_shop()

func _on_accessories_button_pressed():
	current_category = accessories
	populate_shop()
