extends CharacterBody2D

# === CONSTANTS ===
const MAX_SPEED = 200.0
const ROLL_MULTIPLIER = 2.5
# === ENUM ===
enum MovementMode { DIRECTIONAL, ROTATIONAL }

# === EXPORTED VARIABLES ===
@export var movement_mode: MovementMode = MovementMode.DIRECTIONAL
@export var BombScene: PackedScene = preload("res://scenes/Bomb.tscn")
@export var throw_offset: float = 2.0
@export var max_health: int = 100
@export var damage_immunity_time: float = 2.0
@export var hit_freeze_time: float = 0.2
@export var meleeDamage: int = 100
var hookRange :int =600
# === TIMERS ===
@onready var rollCoolDown: Timer = $rollCoolDown
@onready var immunity_frames: Timer = $immunityFrames

# === NODES ===
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var hurt_box: Area2D = $Area2D
@onready var coin_map: TileMap = get_parent().get_node("CanvasLayer/coinCounterMap")

@onready var  hook_scene:PackedScene=preload("res://scenes/hook.tscn");
@onready var hook_timer: Timer = $hookTimer

# === STATE VARIABLES ===
var health: int = max_health
var is_attacking: bool = false
var is_rolling: bool = false
var is_running:bool = false
var can_roll: bool = true
var can_be_damaged: bool = true
var is_frozen: bool = false
var money: int = 0
var can_hook: bool = true
var hookColldown:int =2
@export var isHooking:bool=false
var hook
# === INIT ===
func _ready() -> void:
	add_to_group("player")
	


# === COLLECT COINS ===
func collect(val: int) -> void:
	money += val
	updateCoinCounter()

func updateCoinCounter() -> void:
	if coin_map:
		coin_map.clear()
		var coin_string = str(money)
		for i in coin_string.length():
			var digit = int(coin_string[i])
			var atlas_coord = Vector2i(digit, 0)
			var cell_pos = Vector2i(i, 0)
			coin_map.set_cell(0, cell_pos, 0, atlas_coord)

# === ATTACK ===
func perform_attack() -> void:

	is_attacking = true
	velocity = Vector2.ZERO

	sprite.play("attack")
func perform_hook()->void:
	if can_hook:
		hook_timer.start(hookColldown)
		can_hook=false
		is_running=false
		if hook==null:
			hook=hook_scene.instantiate();
			var mouse_pos = get_global_mouse_position()
			var dir = (mouse_pos - global_position).normalized()
			hook.global_position = position+Vector2(20,20)
			hook.start(dir,hookRange,global_position)
			get_tree().get_current_scene().add_child(hook)
	

	
# === PHYSICS ===
func _physics_process(_delta: float) -> void:
	if is_attacking:
		sprite.play("attack")
	elif is_rolling:
		sprite.play("roll")
	elif is_running:
		sprite.play("run")
	elif  is_attacking:
		sprite.play("attack")
	else:
		sprite.play("idle")
	if is_frozen:
		move_and_slide()
		return

	if not is_attacking and not is_rolling and not isHooking:
		if Input.is_action_just_pressed("bomb"):
			_throw_bomb()
		elif Input.is_action_just_pressed("attack"):
			perform_attack()
			move_and_slide()
		elif Input.is_action_just_pressed("hook") :
			perform_hook()
			move_and_slide();
			return

	if is_attacking or is_rolling:
		move_and_slide()
		return

	var input_vec = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	if input_vec.length() > 0 && hook==null:
		is_running=true
		input_vec = input_vec.normalized()
		velocity = input_vec * MAX_SPEED

		if Input.is_action_just_pressed("roll") and can_roll:
			rollCoolDown.start(2.0)
			can_roll = false
			is_rolling = true
			start_immunity(damage_immunity_time)
			velocity *= ROLL_MULTIPLIER
			sprite.play("roll")
			is_running=false
		
	
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	if input_vec.x < 0:
		sprite.flip_h = true
	elif input_vec.x > 0:
		sprite.flip_h = false


	move_and_slide()

# === ANIMATION FINISHED ===
func _on_animation_finished() -> void:
	var anim = sprite.animation
	
	if anim == "roll":
		is_rolling = false
		velocity = Vector2.ZERO
	elif anim == "attack":
		is_attacking = false


	if not is_attacking and not is_rolling:
		if velocity.length() > 0:
			is_running=true
			sprite.play("running")
		else:
			sprite.play("idle")

# === THROW BOMB ===
func _throw_bomb() -> void:
	#var bomb = BombScene.instantiate()
	#bomb.owner_node = self
	#var dir = (get_global_mouse_position() - global_position).normalized()
	#bomb.global_position = global_position + dir * throw_offset
	#bomb.velocity = dir * bomb.speed
	#get_tree().current_scene.add_child(bomb)
	print("pow")

# === ROLL COOLDOWN ===
func _on_roll_cool_down_timeout() -> void:
	can_roll = true

func take_damage (dmg:int)->void:
	health-=dmg;
	if can_be_damaged:
		can_be_damaged = false
		is_attacking = false
		take_damage(dmg)
		
		health -= dmg
		if health <= 0:
			die()
			

		flash_sprite()

		#await get_tree().create_timer(hit_freeze_time).timeout
		if immunity_frames.time_left<=0:
			start_immunity(2)
# === DAMAGE HANDLER ===
#func _on_hurt_box_body_entered(body: Node2D) -> void:
	#
	#print("body")
	#

# === FLASH EFFECT ===
func flash_sprite():
	var original_modulate = sprite.modulate
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_modulate

# === IMMUNITY END ===
func _on_immunity_frames_timeout() -> void:
	collision_shape_2d.disabled = false
	hurt_box.monitorable=true
	hurt_box.monitoring=true
	can_be_damaged = true
	is_frozen = false

# === DEATH ===
func die() -> void:
	print("Dead")

func start_immunity(time: float) -> void:
	if immunity_frames.time_left <= 0:
 # Safe modification of physics properties
		collision_shape_2d.set_deferred("disabled", true)
		hurt_box.set_deferred("monitorable", false)
		hurt_box.set_deferred("monitoring", false)
		can_be_damaged = false
		 
		immunity_frames.start(time)
func _on_hook_timer_timeout() -> void:
	can_hook=true

	pass # Replace with function body.
