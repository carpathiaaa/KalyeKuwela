extends Node2D

@onready var countdown_timer = $countdown_timer
@onready var pointer_animation = $click_bar/pointer_animation
@onready var sandal = $sandal
@onready var sandal_spin = $sandal/sandal_spin
@onready var sandal_scale = $sandal/sandal_scale
@onready var pointer_button = $click_bar/bar_button

var _level : int = 1
var _coins : int = 0
var _points : int = 0

var scene_time = 15

func _ready() -> void:
	countdown_timer.timeout.connect(first_countdown_timeout)
	stop_controls() # stop controls while waiting for initial countdown timeout

func first_countdown_timeout() -> void:
	print("start of first phase")
	play_sandal_animations()
	resume_controls() # resume controls after initial countdown
	# connect countdown timer to second timeout function
	countdown_timer.timeout.disconnect(first_countdown_timeout)
	countdown_timer.timeout.connect(second_countdown_timeout)
	countdown_timer.start(scene_time)

func stop_controls() -> void:
	pointer_animation.stop() # pause pointer movement before countdown timer expires
	pointer_button.disabled = true # disable button before countdown timer expires

func resume_controls() -> void:
	pointer_animation.play()
	pointer_button.disabled = false

func play_sandal_animations() -> void:
	sandal.visible = true
	sandal_spin.play("sandal_spin")
	sandal_scale.play("sandal_scale")

func second_countdown_timeout() -> void:
	print("end of first phase")
	countdown_timer.timeout.disconnect(second_countdown_timeout)
	
