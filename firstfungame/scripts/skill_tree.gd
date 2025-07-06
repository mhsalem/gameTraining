# skill_tree_manager.gd
extends Node

static var skill_points: int =12
static var all_skills: Array = []

func _ready():
	# Find all skills in the scene
	all_skills = get_tree().get_nodes_in_group("skill")

# Try to unlock a skill
static func try_unlock_skill(skill) -> bool:
	if skill_points < skill.skill_cost:
		return false
	
	if skill.unlock():
		skill_points -= skill.skill_cost
		return true
	return false

# Add skill points
static func add_skill_point(amount: int = 1) -> void:
	skill_points += amount
	update_skill_appearance()

# Update all skills appearance
static func update_skill_appearance() -> void:
	for skill in all_skills:
		skill.update_appearance()
