extends Node2D

# === Exported & Onready ===
@export var cone_angle_deg: float     = 80.0
@export var cone_range: float         = 160.0
@export var knockback_strength: float = 2.0
@export var fire_cooldown: float      = 1.0
@onready var timer: Timer            = $Timer
@onready var smoke_sprite: Sprite2D = $BarrelPivot/Sprite2D2

@onready var barrel  : Node2D    = $BarrelPivot
@onready var muzzle  : Marker2D  = $BarrelPivot/MuzzlePoint

# Optionally change via upgrades
var cone_angle_bonus: float = 0.0
var range_bonus:      float = 0.0

# Internal state
var _cooldown_timer : float = 0.0
var _debug_timer    : float = 0.0
var _debug_world_pts: PackedVector2Array = PackedVector2Array()
var _debug_pts      : PackedVector2Array = PackedVector2Array()

const DEBUG_DURATION = 0.2
const STEPS          = 16
const EPSILON        = 0.05

func get_cone_angle() -> float:
	return cone_angle_deg + cone_angle_bonus

func get_cone_range() -> float:
	return cone_range + range_bonus

func _process(delta: float) -> void:
	# -- Cooldown tick
	if _cooldown_timer > 0.0:
		_cooldown_timer = max(_cooldown_timer - delta, 0.0)

	# -- Aim barrel & flip sprite vertically
	var dir_angle = (get_global_mouse_position() - barrel.global_position).angle()
	barrel.rotation = dir_angle
	var spr = barrel.get_node("Sprite2D") as Sprite2D
	var deg = rad_to_deg(dir_angle)
	spr.flip_v = deg > 90 or deg < -90

	# -- Shoot if ready
	if Input.is_action_just_pressed("shoot") and _cooldown_timer <= 0.0:
		_shoot_cone()
		_cooldown_timer = fire_cooldown

	# -- Debug cone countdown
	if _debug_timer > 0.0:
		_debug_timer -= delta
		queue_redraw()
		if _debug_timer <= 0.0:
			_debug_world_pts.clear()
			_debug_pts.clear()
			queue_redraw()
func _spawn_smoke() -> void:
	var s = smoke_sprite
	s.visible = true

	var length = get_cone_range()
	var width  = 2.0 * length * tan(deg_to_rad(get_cone_angle() * 0.5))

	s.scale.x = length / s.texture.get_width()
	s.scale.y = width  / s.texture.get_height()

	s.global_position = muzzle.global_position
	s.global_rotation = barrel.global_rotation



func _shoot_cone() -> void:
	# start timer to clear debug cone
	
	_spawn_smoke()
	timer.start(0.3)  # show for 0.3s

	# build debug cone geometry
	var origin  = muzzle.global_position
	var forward = Vector2.RIGHT.rotated(barrel.global_rotation)
	var half_ang = deg_to_rad(get_cone_angle() * 0.5)
	var cos_half = cos(half_ang)

	var world_pts = [origin]
	for i in range(STEPS + 1):
		var a = lerp(-half_ang, half_ang, float(i) / STEPS)
		world_pts.append(origin + forward.rotated(a) * get_cone_range())
	_debug_world_pts = PackedVector2Array(world_pts)

	var local_pts = world_pts.map(func(wp):
		return to_local(wp)
	)
	_debug_pts = PackedVector2Array(local_pts)
	_debug_timer = DEBUG_DURATION
	queue_redraw()

	# apply damage/knockback to enemies in cone
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		var to_e = enemy.global_position - origin
		var dist = to_e.length()
		if dist > get_cone_range():
			continue
		var dir_n = to_e / dist
		if forward.dot(dir_n) + EPSILON >= cos_half:
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(dir_n * knockback_strength)
			if enemy.has_method("take_damage"):
				enemy.take_damage(70)
			elif "velocity" in enemy:
				enemy.velocity += dir_n * knockback_strength

func _draw() -> void:
	if _debug_pts.size() > 1:
		draw_colored_polygon(_debug_pts, Color(1, 0, 0, 0.3))

func _on_timer_timeout() -> void:
	# clear debug cone when timer fires
	smoke_sprite.visible = false
	_debug_world_pts.clear()
	_debug_pts.clear()
	queue_redraw()
