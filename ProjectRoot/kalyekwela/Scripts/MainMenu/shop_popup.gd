extends Control

@onready var items_container = $MarginItems/ItemsContainer
@onready var purchase_popup = $PurchasePopUp
@onready var item_name_label = $PurchasePopUp/ItemLabelPriceMargin/VBoxContainer/ItemName
@onready var item_price_label = $PurchasePopUp/ItemLabelPriceMargin/VBoxContainer/ItemPrice
@onready var item_icon = $PurchasePopUp/IconMargin/ItemIcon
@onready var characters_button = $Category/CategoryContainer/CharactersButton
@onready var accessories_button = $Category/CategoryContainer/AccessoriesButton
@onready var confirm_button = $PurchasePopUp/ConfimationActionMargin/ConfirmationContainer/ConfirmButton
@onready var not_enough_coins_popup = $PurchaseNotifPopUp
@onready var ok_button = $PurchaseNotifPopUp/VBoxContainer/OKButton
@onready var coin_label = $"../CurrencyDisplay"

@onready var click_sound = $"../ClickSound"
@onready var click_sound_2 = $"../ClickSound2"
@onready var purchase_sound = $"../PurchaseSound"

var characters = [
	{"name": "Antonio", "price": 100, "icon": preload("res://Assets/Art/CharacterIcons/Character_Antonio_Icon.png")},
	{"name": "Carlo", "price": 150, "icon": preload("res://Assets/Art/CharacterIcons/Character_Carlo_Icon.png")},
	{"name": "Reyna", "price": 300, "icon": preload("res://Assets/Art/CharacterIcons/Character_Reyna_Icon.png")},
	{"name": "Tala", "price": 350, "icon": preload("res://Assets/Art/CharacterIcons/Character_Tala_Icon.png")},
]

var accessories = [
	{"name": "Cool Hat", "price": 50, "icon": preload("res://Assets/Art/CharacterIcons/Character_Reyna_Icon.png")},
	{"name": "Glasses", "price": 75, "icon": preload("res://Assets/Art/CharacterIcons/Character_Tala_Icon.png")},
]

var current_category = characters  # Default to Characters
var selected_item = null

@onready var shop_slot_template = $MarginItems/ItemsContainer/ShopSlot  # Template reference

func _ready():
	not_enough_coins_popup.visible = false
	shop_slot_template.visible = false  # Ensure template is hidden initially
	populate_shop()

func populate_shop():
	if not shop_slot_template:
		print("Error: ShopSlot template not found!")
		return
	
	# Remove previous items but keep the template
	for child in items_container.get_children():
		if child != shop_slot_template:
			child.queue_free()

	# Filter out purchased items
	var filtered_items = []
	if current_category == characters:
		filtered_items = characters.filter(func(item): return item["name"] not in GlobalData.owned_characters)
	else:
		filtered_items = accessories.filter(func(item): return item["name"] not in GlobalData.owned_accessories)

	# Populate shop
	for item in filtered_items:
		var shop_slot = shop_slot_template.duplicate()
		shop_slot.visible = true

		# Assign values
		var clickable_button = shop_slot.get_node("ClickableSlot")
		var item_name_label = shop_slot.get_node("MarginContainer/ItemName")
		var character_icon = shop_slot.get_node("MarginContainer2/CharacterIcon")

		item_name_label.text = item["name"]
		clickable_button.pressed.connect(func(): _on_item_selected(item))

		if item.has("icon"):
			character_icon.texture = item["icon"]

		items_container.add_child(shop_slot)

func _on_item_selected(item):
	if not item:
		print("Error: No item data received!")
		return

	selected_item = item
	item_name_label.text = item["name"]
	item_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_price_label.text = "Price: " + str(item["price"])
	item_icon.texture = item["icon"]
	purchase_popup.visible = true

func _on_confirm_button_pressed():
	if not selected_item:
		print("No item selected!")
		return

	# Prevent duplicate purchases
	if selected_item["name"] in GlobalData.owned_characters or selected_item["name"] in GlobalData.owned_accessories:
		print("Item already owned!")
		return

	# Check coins
	if GlobalData.coins >= selected_item["price"]:
		GlobalData.coins -= selected_item["price"]

		if current_category == characters:
			GlobalData.owned_characters.append(selected_item["name"])
		else:
			GlobalData.owned_accessories.append(selected_item["name"])
		play_purchase_sound()
		GlobalData.save_data()
		_update_coin_display()
		purchase_popup.hide()
		populate_shop()  # ✅ Refresh the shop to remove purchased item
	else:
		_show_not_enough_coins_popup()

func play_click_sound():
	if click_sound:
		click_sound.play()
		
func play_click_sound_2():
	if click_sound_2:
		click_sound_2.play()
		
func play_purchase_sound():
	if purchase_sound:
		purchase_sound.play()

func _on_cancel_button_pressed():
	play_click_sound_2()
	purchase_popup.visible = false

func _on_characters_button_pressed():
	play_click_sound()
	current_category = characters
	populate_shop()

func _on_accessories_button_pressed():
	play_click_sound_2()
	current_category = accessories
	populate_shop()

func _show_not_enough_coins_popup():
	play_click_sound_2()
	not_enough_coins_popup.visible = true

func _on_ok_button_pressed():
	play_click_sound()
	not_enough_coins_popup.visible = false

func _update_coin_display():
	if coin_label:
		coin_label.text = "Coins: " + format_number(GlobalData.coins)

func format_number(value: int) -> String:
	var str_value = str(value)
	var formatted = ""
	var count = 0

	for i in range(str_value.length() - 1, -1, -1):
		formatted = str_value[i] + formatted
		count += 1
		if count % 3 == 0 and i != 0:
			formatted = "," + formatted

	return formatted
