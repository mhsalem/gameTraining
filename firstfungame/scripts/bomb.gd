extends Node2D

# — Node references — 
@onready var bombArea:     Area2D            = $bombSprite
@onready var bombShape:    CollisionShape2D = $bombSprite/bombArea
@onready var explosionArea: Area2D            = $explodedBomb
@onready var explosionShape: CollisionShape2D = $explodedBomb/explodedArea
@onready var sprite:       AnimatedSprite2D  = $AnimatedSprite2D
@export var speed: float = 400.0
@onready var king: PackedScene = preload("res://scenes/king.tscn")

# — will hold the current movement vector —
var velocity: Vector2 = Vector2.ZERO
var owner_node: Node = null
var isArmed=false;
func _physics_process(delta: float) -> void:
	# move the bomb each frame
	position += velocity * delta
func _ready() -> void:
	bombShape.call_deferred("set","disabled",false)
	#bombShape.disabled  = false
	explosionShape.call_deferred("set","disabled",true)
	#explosionShape.disabled  = true
	sprite.animation_finished.connect(_on_animation_finished);
	get_tree().create_timer(0.1);
	isArmed=true;

func _on_animation_finished():
	if sprite.animation == "exploded":
		queue_free()
func explode()->void:
	# 1) Turn off the bomb’s collision so it can’t re‑trigger:
	#bombArea.monitoring = false
	#bombShape.disabled  = true
	bombShape.call_deferred("set","disabled",true)
	bombArea.call_deferred("set","monitoring",false)
	# 2) Turn on the explosion area:
	#explosionShape.disabled  = false
	#explosionArea.monitoring = true
	explosionShape.call_deferred("set","disabled",false)
	explosionArea.call_deferred("set","monitoring",true)
	velocity=Vector2(0.0,0.0);
	# 3) Play your “explode” animation:
	sprite.play("exploded")
	
	# 4) Now hook up hits against enemies:
	if not explosionArea.is_connected("body_entered", _on_explosion_hit):
		explosionArea.body_entered.connect(_on_explosion_hit)




func _on_bomb_area_body_entered(body: Node) -> void:
	if not isArmed:
		return
	if owner_node != null and body == owner_node:
		return
	explode()



func _on_explosion_hit(body: Node) -> void:
	if body == owner_node or body == self:
		return
	print("Explosion hit:", body.name)

	if body.has_method("take_damage"):
		body.take_damage(50)
	else:
		print("Hit body has no take_damage:", body.name)

func _on_timer_timeout() -> void:
	print("boof")
	explode()
