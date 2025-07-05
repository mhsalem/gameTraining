extends Node2D

const slimeSpeed=40;
# Called when the node enters the scene tree for the first time.
var dir=1;
@onready var left: RayCast2D = $left
@onready var right: RayCast2D = $right

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x+=slimeSpeed*delta*dir;
	if left.is_colliding():
		dir=1;
		$AnimatedSprite2D.flip_h=false
	if right.is_colliding():
		dir=-1;
		$AnimatedSprite2D.flip_h=true
	pass
