extends TumbangPresoPhase

@onready var countdown_timer = $countdown_timer
@onready var movement_joystick = $"user_interface/Virtual Joystick"
@onready var floating_enemy = $enemy_body
@onready var player = $player
@onready var game_scene : = get_parent()
@onready var sandal = $Sandal
@onready var sandal_body = $Sandal/SandalSprite

var random_number = RandomNumberGenerator.new()
var retrieved_sandal : bool = false 

var phase_time : int = 15
var difficulty : int = 1 # Default difficulty

signal sandal_touched

func _ready() -> void:
	print("started")
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
	movement_joystick.queue_free()
	get_parent().player_loses()

func _on_sandal_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Player touched a sandal")
		sandal.queue_free()
		player.modulate = Color(0.75, 1, 0.75)  # Light green using normalized values (0-1)
		retrieved_sandal = true

func _on_safe_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and retrieved_sandal:
		emit_signal('sandal_touched')
		self.queue_free()

func randomize_sandal_position() -> void:
	var random_x = random_number.randf_range(-300, 300)
	var random_y = random_number.randf_range(-300, 300)
	sandal_body.position = Vector2(random_x, random_y)
	print("Sandal position: " + str(sandal.position))
