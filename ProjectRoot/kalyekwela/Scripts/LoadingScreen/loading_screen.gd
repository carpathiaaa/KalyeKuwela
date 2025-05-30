extends Control
var next_scene: String = "res://Scenes/BenteUno/main.tscn"
@onready var trivia_label = $OverlayMargin/BackgroundOverlay/FactMargin/FactLabel
@onready var progress_bar = $ProgressBarMargin/ProgressBar
@onready var background_texture_rect = $TextureRect

var last_progress = 0.0
var artificial_progress: float = 0.0
var progress_speed: float = 10.0  # Lower = slower
var pending_trivia_text: String = ""

func set_trivia_text(text: String):
	print("set_trivia_text() CALLED")
	pending_trivia_text = text
	print("Trivia Text Stored: ", text)
	
	if trivia_label:
		trivia_label.text = text
		print("Trivia Set Immediately: ", text)

	
func play_audio(stream: AudioStream):
	$AudioPlayer.stream = stream
	$AudioPlayer.play()

func _ready():
	# Check for metadata first
	if get_tree().has_meta("loading_trivia"):
		var trivia = get_tree().get_meta("loading_trivia")
		pending_trivia_text = trivia
		get_tree().remove_meta("loading_trivia")
		#print("Found trivia from metadata: ", trivia)
	
	if get_tree().has_meta("loading_audio"):
		var audio = get_tree().get_meta("loading_audio") 
		get_tree().remove_meta("loading_audio")
		if audio:
			play_audio(audio)
			#print("Playing audio from metadata")
	
	if get_tree().has_meta("loading_next_scene"):
		next_scene = get_tree().get_meta("loading_next_scene")
		get_tree().remove_meta("loading_next_scene")
		#print("Found next scene from metadata: ", next_scene)
	
	if get_tree().has_meta("loading_background"):
		var bg_texture = get_tree().get_meta("loading_background")
		get_tree().remove_meta("loading_background")
		if bg_texture and background_texture_rect:
			background_texture_rect.texture = bg_texture
			#print("Background texture set from metadata")

	
	# Start loading the scene
	ResourceLoader.load_threaded_request(next_scene, "")
	
	# Set the trivia text that might have been set before _ready()
	if pending_trivia_text != "" and trivia_label:
		trivia_label.text = pending_trivia_text
		#print("Trivia Set in _ready(): ", pending_trivia_text)

	
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
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(packed_next_scene)
