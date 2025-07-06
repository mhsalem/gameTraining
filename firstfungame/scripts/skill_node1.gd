# dash_skill.gd
extends "res://scripts/base_skill.gd"
func _ready() -> void:
	skill_name="dash"
	super()
	
# Override apply effect
func apply_effect() -> void:
	super()  # Call base method if needed
	if player:
		player.has_dash = true
		print("Dash unlocked for player!")
