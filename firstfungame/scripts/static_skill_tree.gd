# SkillTree.gd (Project Settings > Autoload)
extends Node

# Static skill tree data
static var skills = {
	"dash": {
		"name": "Dash",
		"description": "Press SHIFT to dash quickly",
		"icon": null,  # We'll add this later
		"cost": 2,
		"connections": []  # Skills required before unlocking
	},
	"double_jump": {
		"name": "Double Jump",
		"description": "Jump a second time in mid-air",
		"icon": null,
		"cost": 3,
		"connections": ["dash"]  # Requires dash first
	}
}

static var skill_points: int = 0
static var unlocked_skills = {}  # Tracks unlocked skills

# Check if a skill is unlocked
static func is_skill_unlocked(skill_id: String) -> bool:
	return unlocked_skills.has(skill_id)

# Unlock a skill if possible
static func unlock_skill(skill_id: String, player: Node) -> bool:
	# Validate the skill exists
	if not skills.has(skill_id):
		return false
	
	# Check if already unlocked
	if is_skill_unlocked(skill_id):
		return false
	
	# Check if player has enough points
	if skill_points < skills[skill_id]["cost"]:
		return false
	
	# Check prerequisites
	for req in skills[skill_id]["connections"]:
		if not is_skill_unlocked(req):
			return false
	
	# Unlock the skill
	unlocked_skills[skill_id] = true
	skill_points -= skills[skill_id]["cost"]
	
	# Apply skill effect to player
	match skill_id:
		"dash":
			player.has_dash = true
		"double_jump":
			player.max_jumps = 2
	
	return true

# Add skill points
static func add_skill_points(amount: int) -> void:
	skill_points += amount
