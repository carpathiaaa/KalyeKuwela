extends CanvasLayer

@onready var transition_in_sound = $TransitionInSound
@onready var transition_out_sound = $TransitionOutSound
@onready var secure_overlay = $ColorRect

func _ready():
	transition_in_sound.stream = load("res://Assets/Audio/SFX/SFX_TransitionIn.mp3")
	transition_out_sound.stream = load("res://Assets/Audio/SFX/SFX_TransitionOut.mp3")


func load_scene(target_scene: String):
	# Play closing animation and sound
	secure_overlay.visible = true
	transition_out_sound.play()
	$AnimationPlayer.play('RESET')
	await $AnimationPlayer.animation_finished
	secure_overlay.visible = false
	# Change scene
	get_tree().change_scene_to_file(target_scene)
	
	# Play opening animation and sound
	transition_in_sound.play() 
	$AnimationPlayer.play_backwards('RESET')
	secure_overlay.visible = true
	
	await get_tree().create_timer(1.5).timeout
	
	secure_overlay.visible = false

func transition_to_loading_screen(loading_screen_path: String, trivia_text: String, audio: AudioStream, next_scene: String, background: Texture):
	# Play closing animation with sound
	transition_out_sound.play()
	$AnimationPlayer.play('RESET')
	await $AnimationPlayer.animation_finished
	
	# Store data for the loading screen to use
	get_tree().set_meta("loading_trivia", trivia_text)
	get_tree().set_meta("loading_audio", audio)
	get_tree().set_meta("loading_next_scene", next_scene)
	get_tree().set_meta("loading_background", background)
	# Change to the loading screen scene
	get_tree().change_scene_to_file(loading_screen_path)
	
	# Play opening animation with sound
	transition_in_sound.play()
	$AnimationPlayer.play_backwards('RESET')

func load_packed_scene(packed_scene: PackedScene):
	# Play closing animation with sound
	transition_out_sound.play()
	$AnimationPlayer.play('RESET')
	await $AnimationPlayer.animation_finished
	
	# Change scene
	get_tree().change_scene_to_packed(packed_scene)
	
	# Play opening animation with sound
	transition_in_sound.play()
	$AnimationPlayer.play_backwards('RESET')

func reload_scene():
	# Play closing animation with sound
	transition_out_sound.play()
	$AnimationPlayer.play('RESET')
	await $AnimationPlayer.animation_finished
	
	# Reload scene
	get_tree().reload_current_scene()
	
	# Play opening animation with sound
	transition_in_sound.play()
	$AnimationPlayer.play_backwards('RESET')
