extends CharacterBody2D
const SPEED = 150.0
const JUMP_VELOCITY = -350.0
var doubleJump=false;
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	#flip sprite
	if velocity.x>0 :
		animated_sprite_2d.flip_h=false	
	elif velocity.x<0 :
		animated_sprite_2d.flip_h=true
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.play("jump")
	if is_on_floor():
		
		doubleJump=true
		#play animation
	if direction==0:
		animated_sprite_2d.play("idle")
	else :
		animated_sprite_2d.play("run")
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or doubleJump):
		print("onflo",is_on_floor())
		if not is_on_floor():
			doubleJump=false;
		elif is_on_floor():
			doubleJump=true;
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
