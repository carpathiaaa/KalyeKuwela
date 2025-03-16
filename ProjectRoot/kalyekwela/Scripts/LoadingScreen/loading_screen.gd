extends Control

var next_scene: String = "res://Scenes/BenteUno/main.tscn"
@onready var progress_bar = $NinePatchRect/ProgressBarMargin/ProgressBar

var last_progress = 0.0


func _ready():
	ResourceLoader.load_threaded_request(next_scene, "")
	
func _process(delta):
	var progress = []
	var loaded_status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	var new_progress = progress[0] * 100
	
	if new_progress > last_progress:
		last_progress = new_progress
	
	
	progress_bar.value = lerp(progress_bar.value, last_progress, delta * 5)
	
	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progress_bar.value = 100.0
		var packed_next_scene = ResourceLoader.load_threaded_get(next_scene)
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(packed_next_scene)
	pass
