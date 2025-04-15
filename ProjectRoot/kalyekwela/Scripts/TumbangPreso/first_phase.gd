extends TumbangPresoPhase

@onready var countdown_timer = $countdown_timer
@onready var pointer_animation = $click_bar/pointer_animation
@onready var sandal = $sandal
@onready var sandal_spin = $sandal/sandal_spin
@onready var sandal_scale = $sandal/sandal_scale
@onready var pointer_button = $click_bar/bar_button
@onready var click_bar = $click_bar

var initial_countdown_time : int = 3
var phase_time : int = 15

var difficulty : int = 0

func _ready() -> void:
	start_event_sequence()

func start_event_sequence() -> void:
	# Event sequence
	countdown_timer.start(initial_countdown_time)
	initial_stage()
	await countdown_timer.timeout
	main_stage()
	countdown_timer.start(phase_time)
	await countdown_timer.timeout
	get_parent().end_first_phase()

func update_phase(level : int, new_phase_time :int, new_countdown_time: int) -> void:
	print("Updated first phase difficulty : " + str(level))
	difficulty = level
	print("Updated irst phase timer : " + str(new_phase_time))
	phase_time = new_phase_time
	initial_countdown_time = new_countdown_time

func update_phase_rewards(new_coins, new_exp) -> void:
	get_parent().add_rewards(new_coins, new_exp)

func initial_stage() -> void:
	sandal.visible = false
	stop_controls() # stop controls while waiting for initial countdown timeout
	self.show()

func main_stage() -> void:
	print("first countdown")
	play_sandal_animations()
	resume_controls() # resume controls after initial countdown

func resume_controls() -> void:
	pointer_animation.play()
	pointer_button.disabled = false

func stop_controls() -> void:
	pointer_animation.stop() # pause pointer movement before countdown timer expires
	pointer_button.disabled = true # disable button before countdown timer expires

func play_sandal_animations() -> void:
	sandal.visible = true
	sandal_spin.play("sandal_spin")
	sandal_scale.play("sandal_scale")

func stop_sandal_animations() -> void:
	sandal.visible = false
	sandal_spin.stop()
	sandal_scale.stop()
