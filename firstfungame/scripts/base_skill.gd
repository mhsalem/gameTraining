# base_skill.gd
extends Node2D

# Configuration
@export var skill_name: String = "Unnamed Skill"
@export var skill_cost: int = 1
@export var skill_description: String = "Skill description"
@export var skill_icon: Texture2D
@export var required_skills: Array[NodePath] = []  # Paths to prerequisite skills

# State
var unlocked: bool = false
var player: Node = null

# Nodes
@onready var button: Button = $Button
@onready var cost_label: Label = $CostLabel
@onready var name_label: Label = $NameLabel

func _ready():
	# Set up UI
	#button.text = skill_name
	cost_label.text = "Cost: " + str(skill_cost)
	name_label.text = skill_name
	
	# Initial state
	update_appearance()
	
	# Connect button
	button.pressed.connect(_on_pressed)
# Base functionality - override this in child classes
func apply_effect() -> void:
	print("Applying base skill effect: ", skill_name)
	# This will be overridden by specific skills

# Common unlock logic
func unlock() -> bool:
	if unlocked:
		return false
	
	# Check prerequisites
	if !check_prerequisites():
		print("Prerequisites not met for: ", skill_name)
		return false
	
	# Apply skill effect
	apply_effect()
	unlocked = true
	update_appearance()
	return true

# Check required skills
func check_prerequisites() -> bool:
	for path in required_skills:
		var required_skill = get_node_or_null(path)
		if required_skill and !required_skill.unlocked:
			return false
	return true



# Update visual appearance
func update_appearance() -> void:
	if unlocked:
		button.modulate = Color(0.5, 1, 0.5)  # Green
		button.disabled = true
		cost_label.visible = false
	else:
		button.modulate = Color(1, 1, 1)  # White
		button.disabled = !check_prerequisites()
		cost_label.visible = true

# Button handler
func _on_pressed() -> void:
	if SkillTree.try_unlock_skill(self):
		print("Unlocked: ", skill_name)

# Set player reference
func set_player(ref: Node) -> void:
	player = ref
