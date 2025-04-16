class_name ObjectSpawner
extends Node

@onready var object : PackedScene = null # Object to be spawned
@onready var target_node : Node = null # Node where objects will be spawne
# Called when the node enters the scene tree for the first time.

var objects = [] # Array of spawned objects

func _ready() -> void:
	print("Spawner created")

func set_spawner(new_object : PackedScene, new_target_node : Node) -> void:
	if new_object == null:
		push_error("invalid object input")
	elif not new_target_node:
		push_error("invalid target node") 
	else:
		print("spawner object updated")
		object = new_object
		target_node = new_target_node

func spawn_object(spawn_position : Vector2, z_index : int) -> void:
	if !object || !target_node:  # Check position and object validity
		push_error("Spawner not configured!")
		return # end function execution
	var new_object_instance = object.instantiate()
	objects.append(new_object_instance)
	new_object_instance.position = spawn_position
	new_object_instance.z_index = z_index
	target_node.add_child(new_object_instance)
	print( str(object) + " spawned at " + str(new_object_instance.position))

func clear_objects() -> void:
	for spawned_object in objects:
		if spawned_object != null:
			spawned_object.queue_free()
	objects.clear()
	print("cleared spawned objects")
