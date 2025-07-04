extends Node2D

# Configuration
@export var speed: float = 300.0
@export var damage: int = 200
@export var lifetime: float = 3.0

# Runtime variables
var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0

func initialize(shoot_direction: Vector2, projectile_speed: float):
	direction = shoot_direction
	speed = projectile_speed
	rotation = direction.angle()  # Point in movement direction

func _ready():
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start(2)

func _physics_process(delta):
	position += direction * speed * delta
	distance_traveled += speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()

func _on_lifetime_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#body.take_damage(damage)
		#queue_free()
	pass # Replace with function body.
