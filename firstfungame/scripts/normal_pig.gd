extends CharacterBody2D
class_name NormalPig
var speed = 150
@export var health: int = 90
@export var isHit: bool = false
@export var damage: int = 50

@onready var king: CharacterBody2D = get_tree().get_root().get_node("game/king")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var smallCoin: PackedScene = preload("res://scenes/coin.tscn")

var min_range = 0
var is_dead = false
var saw_player = false
var wander_timer = 1.0
var wander_interval = 1.0
var wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
var knock_timer=0.2

func _ready() -> void:
	add_to_group("enemies");

func take_damage(amount: int) -> void:
	if is_dead: return
	health -= amount

	if health <= 0:
		die()
	else:
		sprite.play("damaged")
		await sprite.animation_finished
		sprite.play("running")

func dieDisable() -> void:
	collision_shape_2d.disabled = true
	area_2d.monitoring = false
	area_2d.monitorable = false

func die() -> void:
	call_deferred("dieDisable")
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("dead")
	await sprite.animation_finished
	var dropped_coin = smallCoin.instantiate()
	dropped_coin.global_position = global_position
	get_parent().add_child(dropped_coin)
	queue_free()

func _physics_process(delta: float) -> void:
	if king == null or health <= 0:
		return
	if knock_timer > 0.0:
		knock_timer -= delta
		move_and_slide()
		return
	var distance = global_position.distance_to(king.global_position)

	if distance > 200 and !saw_player:
		# --- WANDER LOGIC ---
		wander_timer -= delta
		if wander_timer <= 0.0:
			wander_timer = wander_interval
			wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		velocity = wander_direction * speed * 0.5
	if distance < min_range:
			var away = (global_position - king.global_position).normalized()
			velocity = away * speed
	else:
		saw_player = true
		# --- CHASE PLAYER USING NAVIGATION ---
		agent.target_position = king.global_position

		if not agent.is_navigation_finished():
			var next_pos = agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO

	move_and_slide()


func apply_knockback(knock_vec: Vector2) -> void:
	if velocity.x > 0:
		velocity.x *= knock_vec.x
	else:
		velocity.x *= -knock_vec.x
	if velocity.y > 0:
		velocity.y *= knock_vec.y
	else:
		velocity.y *= -knock_vec.y
	knock_timer = 0.2


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
	pass # Replace with function body.
