extends CharacterBody2D

@export var speed: float = 200
var is_chaser: bool = false
var chasers_nearby: int = 0  # Keep track of nearby chasers

@onready var status_label = $StatusLabel
@onready var tag_area = $TagArea  # Reference to Area2D
@onready var animated_sprite = $AnimatedSprite2D  # Reference to AnimatedSprite2D
@onready var chase_sfx = $ChaseSFX  # Sound when being chased
@onready var tag_sfx = $TagSFX  # Sound for tagging or being tagged
@onready var chase_detection_area = $ChaseDetectionArea  # New detection area
@onready var background_music = $BackgroundMusic  # 🌟 Reference to background music
@onready var tween = get_tree().create_tween()  # ✅ Properly create Tween

signal health_changed

@export var max_health: int = 3
@onready var current_health: int = max_health
var invincible = false

func is_player():
	return true
	
func _ready():
	status_label.position.y = -20
	update_status()

func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		update_animation(direction)

	velocity = direction * speed
	move_and_slide()
	
	if not is_chaser and not invincible:
		check_for_overlapping_chasers()

# 🔄 Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("WalkSide")
		animated_sprite.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		animated_sprite.play("WalkFront")
	else:
		animated_sprite.play("WalkBack")

# 👹 Convert to a chaser
func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 220  # Slight boost for chasers
		update_status()
		tag_sfx.play()  # 🔊 Play sound for getting tagged
		print(name, " has become a CHASER!")

# 🔴 Updates player status (Runner/Chaser)
func update_status():
	if is_chaser:
		modulate = Color.RED
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		modulate = Color.WHITE
	
	update_chase_sfx()  # 🔊 Ensure chase music updates properly

# 🎵 Handles music fading based on chase state
func update_chase_sfx():
	if not is_chaser and chasers_nearby > 0:
		fade_music(background_music, -30.0, 0.5)  # 🌟 Fade out background music
		fade_music(chase_sfx, 0.0, 0.5)  # 🔊 Fade in chase music
		if not chase_sfx.playing:
			chase_sfx.play()
	else:
		fade_music(background_music, -20, 0.5)  # 🌟 Fade in background music
		fade_music(chase_sfx, -30.0, 0.5)  # 🚫 Fade out chase music

# 🚀 Smoothly fades audio using a Tween
func fade_music(audio: AudioStreamPlayer2D, target_db: float, duration: float):
	if tween.is_valid():
		tween.kill()  # ✅ Only kill if necessary
	tween = get_tree().create_tween()  # ✅ Correctly create a new Tween
	tween.tween_property(audio, "volume_db", target_db, duration)

# 📡 Detect chasers nearby
func _on_chase_detection_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser:
		chasers_nearby += 1
		update_chase_sfx()  # 🔊 Update chase sound based on conditions

func _on_chase_detection_area_body_exited(body):
	if body is CharacterBody2D and body.is_chaser:
		chasers_nearby -= 1
		update_chase_sfx()  # 🔊 Update chase sound based on conditions

func _on_player_tagged_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_chaser and not is_chaser and not invincible:
		print("Player was tagged! Health decreased!")
		current_health -= 1
		print("Player health now: ", current_health)
		
		health_changed.emit(current_health)
		# Check health immediately
		if current_health <= 0:
			become_chaser()
			tag_sfx.play()
			return  # Exit early since becoming a chaser handles everything else
		
		# Only add invincibility if we didn't become a chaser
		invincible = true
		modulate = Color(1, 1, 1, 0.5)  # Semi-transparent to show invincibility
		
		await get_tree().create_timer(1.5).timeout
		
		invincible = false
		if not is_chaser:  # Only reset color if not turned into chaser
			modulate = Color.WHITE
		
		tag_sfx.play()

func _on_tag_area_body_entered(body: Node2D) -> void:
	if is_chaser and body is CharacterBody2D and not body.is_chaser:
		print("Tagged NPC:", body.name)
		tag_sfx.play()
		body.become_chaser()  # Call their chaser logic
		
func check_for_overlapping_chasers():
	for body in $PlayerTaggedArea.get_overlapping_bodies():
		if body is CharacterBody2D and body.is_chaser:
			print("Tagged while standing still!")
			_on_player_tagged_area_body_entered(body)
			break
