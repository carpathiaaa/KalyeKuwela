extends Control

var next_scene: String = "res://Scenes/BenteUno/main.tscn"
@onready var trivia_label = $NinePatchRect/OverlayMargin/BackgroundOverlay/FactMargin/FactLabel
@onready var progress_bar = $NinePatchRect/ProgressBarMargin/ProgressBar



var last_progress = 0.0
var artificial_progress: float = 0.0
var progress_speed: float = 10.0  # Lower = slower

var pending_trivia_text: String = ""

func set_trivia_text(text: String):
	print("set_trivia_text() CALLED")
	pending_trivia_text = text  # Store the text
	print("Trivia Text Stored: ", text)
	
	# If the node is already initialized, set it right away
	if trivia_label:
		trivia_label.text = text
		print("Trivia Set Immediately: ", text)
	# Otherwise it will be set in _ready()
	
func play_audio(stream: AudioStream):
	$AudioPlayer.stream = stream
	$AudioPlayer.play()

func _ready():
	ResourceLoader.load_threaded_request(next_scene, "")
		# Set the trivia text that might have been set before _ready()
	if pending_trivia_text != "" and trivia_label:
		trivia_label.text = pending_trivia_text
		print("Trivia Set in _ready(): ", pending_trivia_text)
	
	if trivia_label:
		print("Trivia Label Exists")
	
func _process(delta):
	var progress = []
	var loaded_status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	var new_progress = progress[0] * 100
	
	if new_progress > last_progress:
		last_progress = new_progress
	
	# Artificially limit how fast progress can increase
	artificial_progress += delta * progress_speed
	var capped_progress = min(artificial_progress, last_progress)
	
	progress_bar.value = capped_progress
	
	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and artificial_progress >= 100.0:
		progress_bar.value = 100.0
		var packed_next_scene = ResourceLoader.load_threaded_get(next_scene)
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(packed_next_scene)
