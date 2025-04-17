class_name EnemySpawner
extends Node


@onready var spawn_node : Node = null
@onready var target : Player = null

var default_z_index : int = 0
var enemy_speed : int = 100
var enemies = [] # Array of spawned enemies

func set_enemy_spawner(new_target : Player, new_spawn_node : Node, new_z : int) -> void:
	if ! (new_spawn_node == null || new_target != Player):
		push_error("invalid enemy spawner parameters")
		print("bruh")
	else: 
		print("Updated enemy spawner")
		spawn_node = new_spawn_node
		target = new_target
		default_z_index = new_z

func spawn_enemy(enemy_class : PackedScene, spawn_position : Vector2, new_speed) -> void:
	if enemy_class:
		enemy_speed = new_speed
		var new_enemy_instance = enemy_class.instantiate()
		new_enemy_instance.set_target(target, enemy_speed)
		new_enemy_instance.z_index = default_z_index 
		new_enemy_instance.position = spawn_position
		enemies.append(new_enemy_instance)
		spawn_node.add_child(new_enemy_instance)
		print("Enemy spawned at " + str(spawn_position))
	else:
		push_error("Invalid enemy class in spawner")
		return

func clear_enemies() -> void:
	for spawned_enemy in enemies:
		if spawned_enemy:
			spawned_enemy.queue_free()
	enemies.clear()
	print("Enemies cleared")
