extends BaseGame

@onready var info_overlay = $"UserInterface/InfoOverlay"
@onready var main_player = $main_player
@onready var coin_sfx = $sound_effects/coin_sfx
@onready var map = $map
@onready var background_music = $Music
@onready var coin = load("res://Scenes/Patintero/coin.tscn")
@onready var short_fence = load("res://Scenes/TumbangPreso/short_fence.tscn")
@onready var long_fence = load("res://Scenes/TumbangPreso/long_fence.tscn")
var random_generator = RandomNumberGenerator.new()
var object_spawner = null

var max_x = 140
var max_y = 240
var object_z_index = 3

var fences = [short_fence, long_fence]

func _ready() -> void:
	# Override default level
	level = 0
	background_music.attenuation = 0.0 # Disable distance-based volume drop
	set_object_spawner()
	spawn_fence(1)

func set_object_spawner() -> void:
	object_spawner = ObjectSpawner.new()
	add_child(object_spawner)

func next_level() -> void:
	level += 1
	info_overlay.update_level_label(level)
	object_spawner.clear_objects()
	print("level " + str(level))
	spawn_coins(level)
	spawn_fence(level)

func spawn_coins(current_level : int) -> void:
	var random_x = 0
	var random_y = 0
	print("spawning coins")
	object_spawner.set_spawner(coin, map)
	for i in current_level:
		random_x = random_generator.randi_range(0, max_x) * i
		random_y = random_generator.randi_range(0, max_y) 
		object_spawner.spawn_object(Vector2(random_x, random_y), object_z_index)

func spawn_fence(current_level : int) -> void:
	var fences_num = current_level * 2
	var fence_type = 0
	var random_y = 0
	for i in range(-1, (2 * current_level) + 2):
		random_y = random_generator.randi_range(0 , max_y)
		if i % 2 == 1:
			random_y *= -1 
		fence_type = random_generator.randi_range(0, fences.size() - 1)
		object_spawner.set_spawner(long_fence, map)
		object_spawner.spawn_object(Vector2(235 * i, random_y), 4)
		

func return_to_main_menu() -> void:
	Engine.time_scale = 1 # Ensure engine processes are not paused after quitting.
	get_tree().change_scene_to_file("res://Scenes/MainMenu/menu.tscn")

func player_death() -> void:
	info_overlay.hide()
	main_player.player_speed = 0
	end_sequence()

func add_points(points_gained : int) -> void:
	exp += points_gained / 10
	info_overlay.update_score_label(points_gained)

func add_level_coins(coins_gained : int) -> void:
	add_coins(coins_gained)
	info_overlay.update_coins_label(coins)
	coin_sfx.play()

func _on_main_player_touched_enemy() -> void:
	print("Player touched enemy")
	player_death()
