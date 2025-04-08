extends HBoxContainer

@onready var heart_gui_class = preload("res://Scenes/BenteUno/heart_gui.tscn")

func _ready():
	pass
	
func _process(delta):
	pass
	
func setMaxHearts(max: int):
	for i in range(max):
		var heart = heart_gui_class.instantiate()
		add_child(heart)

func update_hearts(current_health: int):
	var hearts = get_children()
	
	for i in range(current_health):
		hearts[i].update(true)
	
	for i in range(current_health, hearts.size()):
		hearts[i].update(false)
