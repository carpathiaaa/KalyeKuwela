extends Node2D

@onready var start_area = $start_tile/start_area
@onready var main_tile = $main_tile
@onready var end_tile = $end_tile
@onready var end_area = $end_tile/end_area
@onready var main_patintero = $".."
@onready var return_label = $end_tile/return_label
var score_line = preload("res://Scenes/Patintero/score_line.tscn")
var vertical_bot = preload("res://Scenes/Patintero/vertical_bot.tscn")
var coin = preload("res://Scenes/Patintero/coin.tscn")
var rock = preload("res://Scenes/Patintero/rock.tscn")
var random_number = RandomNumberGenerator.new()
var label_timer : float = 2.0


func _ready() -> void:
	random_number.randomize() # random number generator seed

# array of enemies in vertical lines
var enemy_instances = []
# array of coins per level
var coin_instances = []
# array of rocks per level
var rock_instances = []

func preparelevel() -> void:
	# remove enemies before next level starts
	for enemy in enemy_instances:
		if enemy and enemy.is_inside_tree():
			enemy.queue_free()
	enemy_instances.clear()
	
	# remove rocks before next level starts
	for rock in rock_instances:
		if rock and rock.is_inside_tree():
			rock.queue_free()
	rock_instances.clear()
	
	# remove remaining coins before next level starts
	for coin in coin_instances:
		if (coin != null):
			coin.queue_free()
	coin_instances.clear()
	
	extend_map(Vector2(470 * main_patintero.level, 0))
	end_tile.position = (Vector2(470 * main_patintero.level, 0))
	for i in range(-1, (2 * main_patintero.level) + 2):
		add_coin(140 * i, 250 * i)
		add_rock(140 * i, 250 * i)
		add_score_line(Vector2(235 * i, 0))
		#add_vertical_bot(Vector2(235* i, 0))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func extend_map(main_tile_position) -> void:
	var map_instance = main_tile.duplicate()
	map_instance.position = main_tile_position
	add_child(map_instance)


func add_score_line(line_position) -> void:
	var line_instance = score_line.instantiate()
	line_instance.position = line_position 
	add_child(line_instance)


func add_vertical_bot(enemy_position) -> void:
	var enemy_instance = vertical_bot.instantiate()
	enemy_instance.position = enemy_position
	add_child(enemy_instance)
	enemy_instances.append(enemy_instance)


func add_rock(min_position, max_position) -> void:
	var rock_instance = rock.instantiate()
	rock_instance.z_index = 4
	rock_instance.position.y = random_number.randf_range(-200, 80)
	rock_instance.position.x = random_number.randf_range(min_position, max_position)
	add_child(rock_instance)
	rock_instances.append(rock_instance)	


func add_coin(min_position, max_position) -> void:
	var coin_instance = coin.instantiate()
	coin_instance.position.y = random_number.randf_range(-230, 100)
	coin_instance.position.x = random_number.randf_range(min_position, max_position)
	add_child(coin_instance)
	coin_instances.append(coin_instance)


func _on_start_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("main_player"):
		start_area.position.x = -500  
		main_patintero.next_level()
		preparelevel()



func _on_end_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("main_player"):
		return_label.show()


func _on_end_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("main_player"):
		return_label.hide()
		start_area.position.x = 0
		
	
