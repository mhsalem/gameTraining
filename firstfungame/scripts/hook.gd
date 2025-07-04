extends Node2D

@export var speed: float      = 800.0
@export var max_length: float = 400.0

@onready var rope   := $Line2D
@onready var head   := $Sprite2D
@onready var hitbox := $Hitbox

var origin:    Vector2
var dir:       Vector2
var traveled:  float  = 0.0
var active:    bool   = true

var isHooking: bool = false

func _ready() -> void:

	# Make sure rope starts with zero length:
	rope.points = [ Vector2.ZERO, Vector2.ZERO ]
	head.position = Vector2.ZERO

func start(direction: Vector2, length: float,pos:Vector2) -> void:
	origin     = pos
	dir        = direction.normalized()
	rotation   = dir.angle()
	max_length = length
	traveled   = 0.0
	active     = true
	isHooking = true

func _physics_process(delta: float) -> void:
	if not active:
		return

	# Move tip
	var move_amt = dir * speed * delta
	global_position += move_amt
	traveled += move_amt.length()

	# Compute local points: origin->tip
	var local_origin = to_local(origin)
	var local_tip    = to_local(global_position)

	# Stretch the rope and place the head
	rope.points = [ local_origin, local_tip ]
	head.position = local_tip

	if traveled >= max_length:
		isHooking = false
		queue_free()

func _on_Hitbox_body_entered(body: Node) -> void:
	
	if body.is_in_group("enemies"):
		body.take_damage(30);
		active = false
		call_deferred("pull_player", body.global_position)
		queue_free()

func pull_player(target_pos: Vector2) -> void:
	
	var player = get_tree().get_current_scene().get_node("king")
	player.start_immunity(3)
	var pull_dir = (position - player.global_position).normalized()
	player.get_child(0).play("roll")
	player.is_rolling=true
	
	player.get_child(0).animation_finished.connect(Callable(self, "_on_player_roll_finished"))
	player.position = position 
	player.start_immunity(1);
	
func _on_player_roll_finished(anim_name: String) -> void:
	# Only handle the "roll" animation ending
	if anim_name != "roll":
		return
	var player = get_tree().get_current_scene().get_node("king") as CharacterBody2D
	player.is_rolling = false
	player.position = position  # snap them to the hook tip
