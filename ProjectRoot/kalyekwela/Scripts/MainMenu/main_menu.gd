extends Control

@onready var patintero_button = $MarginContainer/GameButtonsContainer/Patintero
@onready var tumbang_preso_button = $MarginContainer/GameButtonsContainer/TumbangPreso
@onready var bente_uno_button = $MarginContainer/GameButtonsContainer/BenteUno
@onready var currency_display = $CurrencyDisplay
@onready var xp_bar = $XPBar

const LOADING_SCREEN = preload("res://Scenes/LoadingScreen/loading_screen.tscn")

@export var settings_popup: MarginContainer
@export var inventory_popup: MarginContainer
@export var shop_popup: MarginContainer

var current_open_popup: Control = null  # Tracks the currently open sidebar
var is_animating: bool = false  # Prevent multiple fast clicks

# Trivia facts for each game
var patintero_facts = [
	"Did You Know? In patintero, being sneaky is a skill! If you can fake out the defenders, you’re basically a ninja in tsinelas!",
	"Speed is your best friend! The faster you move, the harder it is for the “bantay” to tag you. But careful—trip and you might face-plant on the kalsada!",
	"Mind games, tropa! Make eye contact with the defender, pretend to run, then BAM—swerve in the other direction! That’s how pros do it!",
	"OG night mode? Before video games had 'dark mode,' kids played patintero under the moonlight! No electricity? No problem! Just pure larong Pinoy fun.",
	"Street Smarts Required! In patintero, you need fast reflexes, a good strategy, and a little bit of diskarte—kind of like dodging your nanay’s tsinelas when you forget to do chores!",
	"Patintero but make it digital? Imagine power-ups like 'Takbo Turbo' (speed boost) or 'Bantay Lockdown' (freezing defenders in place). That’s what Kalye Kuwela is bringing to the table!"
]

var tumbang_preso_facts = [
	"Lata > Expensive Toys – Who needs fancy gadgets when you have an empty can and a tsinelas? Tumbang Preso proves that the best games are made from pure Pinoy creativity!",
	"Your tsinelas is your secret weapon! But choose wisely—rubber tsinelas fly straight, while old-school Spartan slippers? Good luck aiming with those!",
	"Angat mo ‘yan! The higher the lata flips, the longer the bantay panics! If you can send it flying across the street, that’s an automatic MVP moment!",
	"Tsinelas Physics 101 – A well-aimed slipper can knock the can over from a crazy distance! Just don’t let your nanay see you using her favorite tsinelas… or you’ll be the one running!",
	"Ultimate Diskarte Move – When the bantay is distracted, run like there’s no tomorrow and rescue your slipper! But don’t get caught, or you’re the next preso!"
]


var bente_uno_facts = [
	"Not Just a Number! 'Bente Uno' means 21, but in this game, it’s also the countdown to your escape—or your doom! Can you outsmart the tagger before the last count?",
	"Sprint or Strategize? Some players dash away instantly, while others hide in plain sight like a true master of diskarte. Which one are you?",
	"The Art of the Fake Freeze! Ever pretended to be a statue mid-run? Pro tip: If you freeze just right, the tagger might miss you—until your friend sneezes and gets you all caught!",
	"Speed Demons Wanted! If you can break past the tagger and reach base safely, congratulations—you have officially unlocked Pinoy Flash Mode!",
	"Hide-and-Seek x Patintero? Bente Uno is like a mashup of classic games, with the thrill of running, hiding, and perfectly timing your moves. It’s why it’s been a kalye favorite for decades!"
]


func _init():
	GlobalData.load_data()  # ✅ Load data early to avoid null values

func update_ui():
	currency_display.text = "Coins: " + format_number(GlobalData.coins)
	var xp_required = GlobalData.get_xp_required(GlobalData.level)
	xp_bar.value = float(GlobalData.xp) / xp_required * 100  # Set bar percentage

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


func _ready():
	GlobalData.load_data()  # Load saved data
	update_ui()  # Ensure UI reflects loaded data
	patintero_button.pressed.connect(start_patintero)
	tumbang_preso_button.pressed.connect(start_tumbang_preso)
	bente_uno_button.pressed.connect(start_bente_uno)

# Function to get a random trivia fact
func get_random_fact(facts: Array) -> String:
	if facts.size() > 0:
		var fact = facts[randi() % facts.size()]
		print("Selected Trivia: ", fact)  # ✅ Debugging: Check if trivia is being selected
		return fact
	return "Enjoy the game!"

func start_patintero():
	var loading_scene = LOADING_SCREEN.instantiate()
	loading_scene.next_scene = "res://Scenes/Patintero/main.tscn"
	add_child(loading_scene)
	loading_scene.set_trivia_text(get_random_fact(patintero_facts))  # ✅ Set random fact

func start_tumbang_preso():
	var loading_scene = LOADING_SCREEN.instantiate()
	loading_scene.next_scene = "res://Scenes/TumbangPreso/main.tscn"
	add_child(loading_scene)
	loading_scene.set_trivia_text(get_random_fact(tumbang_preso_facts))  # ✅ Set random fact

func start_bente_uno():
	var loading_scene = LOADING_SCREEN.instantiate()
	loading_scene.next_scene = "res://Scenes/BenteUno/main.tscn"
	add_child(loading_scene)
	loading_scene.set_trivia_text(get_random_fact(bente_uno_facts))  # ✅ Set random fact

# Function to manage popups (ensuring only one is open at a time)
#func toggle_popup(popup: Control):
#	if current_open_popup and current_open_popup != popup:
#		current_open_popup.visible = false  # Close previous popup

# Function to toggle popups properly
func toggle_popup(new_popup: Control):
	# Prevent clicking while animation is running
	if is_animating:
		return

	# If clicking the already open popup, play the exit animation and close it
	if new_popup == current_open_popup:
		close_popup(new_popup)
		return

	# If another popup is open, close it immediately without animation
	if current_open_popup:
		current_open_popup.visible = false  

	# Open the new popup and play the open animation
	new_popup.visible = true
	var anim_player = new_popup.get_node_or_null("AnimationInOut") as AnimationPlayer
	if anim_player:
		is_animating = true
		anim_player.play("TransitionIn")
		await anim_player.animation_finished  
		is_animating = false  

	current_open_popup = new_popup  # Track the open popup

# Function to close a popup with exit animation
func close_popup(popup: Control):
	if is_animating:
		return
	
	var anim_player = popup.get_node_or_null("AnimationInOut") as AnimationPlayer
	if anim_player:
		is_animating = true
		anim_player.play("TransitionOut")
		await anim_player.animation_finished  
		is_animating = false  
	
	popup.visible = false  
	current_open_popup = null  # Reset tracking

func _on_toggle_settings_button_pressed():
	toggle_popup(settings_popup)

func _on_toggle_inventory_button_pressed():
	toggle_popup(inventory_popup)

func _on_toggle_shop_button_pressed():
	toggle_popup(shop_popup)

# Connect this function to the exit button inside each popup
func _on_exit_button_pressed():
	if current_open_popup:
		close_popup(current_open_popup)	
