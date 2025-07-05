extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -250.0
const ROTATION_SPEED = 8.0  # Increased for faster response

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Reset on collision
	if is_on_wall() or is_on_ceiling() or is_on_floor():
		get_tree().reload_current_scene()
	
	# Apply gravity
	velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		# Immediate upward tilt on jump
		animated_sprite_2d.rotation = deg_to_rad(-30)
	
	# Calculate target rotation
	var target_rotation = 0.0
	
	if velocity.y > 0:  # Falling
		# More gradual falling rotation
		target_rotation = deg_to_rad(lerp(0, 90, min(velocity.y / 500.0, 1.0)))
	elif velocity.y < 0:  # Rising
		# More subtle upward tilt
		target_rotation = deg_to_rad(lerp(0, -30, min(-velocity.y / JUMP_VELOCITY/2, 1.0)))
	
	# Smoothly rotate toward target with clamping
	animated_sprite_2d.rotation = lerp(
		animated_sprite_2d.rotation, 
		target_rotation, 
		ROTATION_SPEED * delta
	)
	
	# Prevent over-rotation
	animated_sprite_2d.rotation = clamp(
		animated_sprite_2d.rotation,
		deg_to_rad(-30),  # Max upward tilt
		deg_to_rad(90)    # Max downward tilt
	)
	
	move_and_slide()
