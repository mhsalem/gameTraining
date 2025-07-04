extends Node2D

@onready var pigScene: PackedScene = preload("res://scenes/normal_pig.tscn")
@onready var fastPig: PackedScene = preload("res://scenes/ranged_pig.tscn")
@onready var king: CharacterBody2D = $king
@export var MenuScene: PackedScene = preload("res://scenes/menu.tscn")

# Tracks if menu is open and holds its instance
var menu_instance: Node = null

func _process(_delta: float) -> void:
	# Toggle menu when pressing the menu key
	if Input.is_action_just_pressed("menu"):
		if menu_instance == null:
			# Open menu: instantiate under the camera so it follows player
			menu_instance = MenuScene.instantiate()
			king.get_node("./Camera2D").add_child(menu_instance)
			menu_instance.position = Vector2.ZERO
			get_tree().paused = true
		else:
			# Close menu
			get_tree().paused = false
			menu_instance.queue_free()
			menu_instance = null

func _on_timer_timeout() -> void:
	var pig = pigScene.instantiate()
	var fPig=fastPig.instantiate()
	#pig.global_position = king.global_position + Vector2(randi_range(20, 222), randi_range(20, 222))
	fPig.global_position = king.global_position + Vector2(randi_range(20, 222), randi_range(20, 222))
	#get_parent().add_child(pig)
	get_parent().add_child(fPig)
