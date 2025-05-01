extends BaseGame

@onready var info_overlay = $"UserInterface/InfoOverlay"
@onready var main_player = $main_player
@onready var coin_sfx = $sound_effects/coin_sfx
@onready var map = $map
@onready var background_music = $main_player/Music

@onready var coin = preload("res://Scenes/Patintero/coin.tscn")
@onready var short_fence = preload("res://Scenes/TumbangPreso/short_fence.tscn")
@onready var long_fence = preload("res://Scenes/TumbangPreso/long_fence.tscn")
@onready var rock = preload("res://Scenes/Patintero/rock.tscn")

@onready var vertical_float_enemy = preload("res://Scenes/Patintero/vertical_float_enemy.tscn")
@onready var random_float_enemy = preload("res://Scenes/Patintero/random_float_enemy.tscn")
@onready var loop_float_enemy = preload("res://Scenes/Patintero/loop_float_enemy.tscn")

var location_string = "res://Scenes/Patintero/main.tscn"

var random_generator = RandomNumberGenerator.new()
var object_spawner : ObjectSpawner = null
var enemy_spawner : EnemySpawner = null

signal change_level(current_level)

var min_x = -190
var max_x = 140
var min_y = -180
var max_y = 150
var object_z_index = 2

 
func _ready() -> void:
	# Override default level
	current_game = location_string
	level = 0
	info_overlay.hide_timer_label() 
	info_overlay.hide_score_label()
	set_object_spawner()
	set_enemy_spawner()

func set_object_spawner() -> void:
	object_spawner = ObjectSpawner.new()
	add_child(object_spawner)

func set_enemy_spawner() -> void:
	enemy_spawner = EnemySpawner.new()
	add_child(enemy_spawner)

func next_level() -> void:
	level += 1
	emit_signal("change_level", level)
	info_overlay.update_level_label(level)
	object_spawner.clear_objects()
	enemy_spawner.clear_enemies()
	print("level " + str(level))
	spawn_enemy(level)
	spawn_coins(level + 1)
	spawn_rocks(level + 1)
	spawn_fence(level + 1)

func spawn_coins(current_level : int) -> void:
	var random_x = 0
	var random_y = 0
	print("spawning coins")
	object_spawner.set_spawner(coin, map)
	for i in current_level:
		random_x = random_generator.randi_range(min_x - 20, max_x) * i
		random_y = random_generator.randi_range(min_y, max_y) 
		object_spawner.spawn_object(Vector2(random_x, random_y), object_z_index)

func spawn_rocks(current_level : int) -> void:
	var random_x = 0
	var random_y = 0
	print("spawning rocks")
	object_spawner.set_spawner(rock, map)
	for i in current_level * 4:
		random_x = random_generator.randi_range(min_x, max_x * i) 
		random_y = random_generator.randi_range(min_y - 10, max_y - 40) 
		object_spawner.spawn_object(Vector2(random_x, random_y), object_z_index)

func spawn_fence(current_level : int) -> void:
	var fences_num = current_level * 2
	var fence_type = 0
	var random_y = 0
	for i in range(-1, (2 * current_level) + 2):
		random_y = random_generator.randi_range(min_y , max_y - 50)
		if i % 2 == 1:
			random_y *= -1 
		fence_type = random_generator.randi_range(0, 1)
		match fence_type:
			0:
				object_spawner.set_spawner(long_fence, map)
				object_spawner.spawn_object(Vector2(235 * i, random_y), 4)
			1:
				object_spawner.set_spawner(short_fence, map)
				object_spawner.spawn_object(Vector2(235 * i, 96), 4)
				object_spawner.spawn_object(Vector2(235 * i, -170), 4)
func spawn_enemy(current_level : int) -> void:
	print("Spawning enemies")
	var random_y = 0
	var enemy_type = 0
	enemy_spawner.set_enemy_spawner(main_player, map, level, 5)
	for i in range(0, (2 * current_level) + 2):
		random_y = random_generator.randi_range(-max_y, max_y)
		match random_generator.randi_range(0, 3):
			0:
				enemy_spawner.spawn_enemy(vertical_float_enemy, Vector2(235 * i, 0), level)
			1:
				enemy_spawner.spawn_enemy(vertical_float_enemy, Vector2(235 * i, 0), level)
			2:
				enemy_spawner.spawn_enemy(loop_float_enemy, Vector2(235* i, 0), level)
			3:
				object_spawner.set_spawner(random_float_enemy, map)
				object_spawner.spawn_object(Vector2(235 * i, 0), 4)
			_:    # Optional: Default case (handles unexpected values)
				push_error("Invalid enemy type")

func player_death() -> void:
	info_overlay.hide()
	main_player.player_speed = 0
	end_sequence()

func add_points(points_gained : int) -> void:
	exp += points_gained 
	info_overlay.update_score_label(points_gained)

func add_level_coins(coins_gained : int) -> void:
	add_coins(coins_gained)
	info_overlay.update_coins_label(coins)
	coin_sfx.play()

func _on_main_player_touched_enemy() -> void:
	print("Player touched enemy")
	player_death()


func _on_change_level(extra_arg_0: int) -> void:
	pass # Replace with function body.
