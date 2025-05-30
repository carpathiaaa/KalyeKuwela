extends CharacterBody2D

@export var speed: float = 200
var is_chaser: bool = false
var chasers_nearby: int = 0  # Keep track of nearby chasers
var last_direction: Vector2 = Vector2.DOWN  # Default facing direction

var can_move: bool = false  # Prevents movement until enabled

@onready var status_label = $StatusLabel
@onready var tag_area = $TagArea 
@onready var animated_sprite = $AnimatedSprite2D 
@onready var chase_sfx = $ChaseSFX 
@onready var tag_sfx = $TagSFX  
@onready var chase_detection_area = $ChaseDetectionArea  
@onready var background_music = $BackgroundMusic  
@onready var tween = get_tree().create_tween()

signal health_changed

@export var max_health: int = 3
@onready var current_health: int = max_health
var invincible = false

func is_player():
	return true
	
func _ready():
	velocity = Vector2.ZERO
	status_label.position.y = -20
	update_status()
	play_idle_animation()
	
	can_move = false
	await get_tree().create_timer(0.01).timeout
	can_move = true

func _physics_process(delta):
	var direction = Vector2.ZERO
	if can_move:
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
			last_direction = direction  # Store the last direction
			update_animation(direction)
		else:
			# No movement, play idle animation based on last direction
			play_idle_animation()
			velocity = Vector2.ZERO

		velocity = direction * speed
		move_and_slide()
		
	else:
		velocity = Vector2.ZERO

	if not is_chaser and not invincible:
		check_for_overlapping_chasers()

# Update animation based on movement direction
func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("WalkSide")
		animated_sprite.flip_h = direction.x < 0  # Flip if moving left
	elif direction.y > 0:
		animated_sprite.play("WalkFront")
	else:
		animated_sprite.play("WalkBack")

# Play idle animation based on last facing direction
func play_idle_animation():
	if abs(last_direction.x) > abs(last_direction.y):
		animated_sprite.play("IdleSide")
		animated_sprite.flip_h = last_direction.x < 0 
	elif last_direction.y > 0:
		animated_sprite.play("IdleFront")
	else:
		animated_sprite.play("IdleBack")

func become_chaser():
	if not is_chaser:
		is_chaser = true
		speed = 220  # Slight boost for chasers
		update_status()
		tag_sfx.play()
		print(name, " has become a CHASER!")

# Updates player status (Runner/Chaser)
func update_status():
	if is_chaser:
		modulate = Color.RED
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		modulate = Color.WHITE
	
	update_chase_sfx()

func update_chase_sfx():
	if not is_chaser and chasers_nearby > 0:
		fade_music(background_music, -30.0, 0.5)
		fade_music(chase_sfx, 0.0, 0.5) 
		if not chase_sfx.playing:
			chase_sfx.play()
	else:
		fade_music(background_music, -20, 0.5)
		fade_music(chase_sfx, -30.0, 0.5)

# Smoothly fades audio using a Tween
func fade_music(audio: AudioStreamPlayer2D, target_db: float, duration: float):
	if tween.is_valid():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(audio, "volume_db", target_db, duration)

# Detect chasers nearby
func _on_chase_detection_area_body_entered(body):
	if body is CharacterBody2D and body.is_chaser:
		chasers_nearby += 1
		update_chase_sfx()

func _on_chase_detection_area_body_exited(body):
	if body is CharacterBody2D and body.is_chaser:
		chasers_nearby -= 1
		update_chase_sfx()

func _on_player_tagged_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_chaser and not is_chaser and not invincible:
		#print("Player was tagged! Health decreased!")
		current_health -= 1
		#print("Player health now: ", current_health)
		
		health_changed.emit(current_health)

		if current_health <= 0:
			become_chaser()
			tag_sfx.play()
			return # Exit logic here since we're a chaser already
		
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
		#print("Tagged NPC:", body.name)
		tag_sfx.play()
		body.become_chaser()
		
func check_for_overlapping_chasers():
	for body in $PlayerTaggedArea.get_overlapping_bodies():
		if body is CharacterBody2D and body.is_chaser:
			#print("Tagged while standing still!")
			_on_player_tagged_area_body_entered(body)
			break
