extends TumbangPresoPhase

@onready var countdown_timer = $countdown_timer
@onready var movement_joystick = $"user_interface/Virtual Joystick"
@onready var map = $map
@onready var floating_enemy = $enemy_body
@onready var player = $player
@onready var game_scene : = get_parent()
@onready var sandal = $Sandal
@onready var sandal_body = $Sandal/SandalSprite
@onready var action_label = $user_interface/action_label
@onready var action_label_timer = $user_interface/action_label/ActionLabelTimer
@onready var rock = preload("res://Scenes/TumbangPreso/large_rock.tscn")
@onready var up_arrow = $map/UpArrow
@onready var down_arrow = $map/DownArrow
@onready var down_arrow_animation = $map/DownArrow/AnimationPlayer
var random_number = RandomNumberGenerator.new()
var object_spawner = ObjectSpawner.new()

var retrieved_sandal : bool = false 
var phase_time : int = 20
var difficulty : int = 1 # Default difficulty
var action_label_time : float = 1.5


signal sandal_touched

func _ready() -> void:
	print("started")
	spawn_rocks(game_scene.level)
	action_label_timer.start(action_label_time)
	randomize_sandal_position() # randomize sandal location 
	countdown_timer.start(phase_time)
	await countdown_timer.timeout
	game_scene.end_second_phase()

func update_phase(level : int, new_phase_time :int, countdown_time :int) -> void:
	print("Updated second phase difficulty : " + str(level))
	difficulty = level
	print("Updated second phase timer : " + str(new_phase_time))
	phase_time = new_phase_time

func _on_player_touched_enemy() -> void:
	print("Player touched an enemy")
	if movement_joystick:
		movement_joystick.queue_free()
	game_scene.end_sequence()

func _on_sandal_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Player touched a sandal")
		action_label_timer.start(action_label_time)
		action_label.text = "Return"
		action_label.show()
		sandal.queue_free()
		player.self_modulate = Color(0.75, 1, 0.75)  # Light green using normalized values (0-1)
		retrieved_sandal = true
		up_arrow.hide()
		down_arrow.show()
		down_arrow_animation.play("down_arrow")



func _on_safe_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and retrieved_sandal:
		action_label_timer.start(3)
		emit_signal('sandal_touched')
		await action_label_timer.timeout
		self.queue_free()

func randomize_sandal_position() -> void:
	var random_x = random_number.randf_range(-100, 100)
	var random_y = random_number.randf_range(-200, 100)
	sandal_body.position.x += random_x
	sandal_body.position.y += random_y
	print("Sandal position: " + str(sandal.position))

func spawn_rocks(current_level : int) -> void:
	var random_x = 0
	var random_y = 0
	print("spawning rocks")
	object_spawner.set_spawner(rock, map)
	for i in current_level * 4:
		random_x = random_number.randi_range(150, 750) 
		random_y = random_number.randi_range(500, 900) 
		object_spawner.spawn_object(Vector2(random_x, random_y), 1)



func _on_action_label_timer_timeout() -> void:
	action_label.hide()
