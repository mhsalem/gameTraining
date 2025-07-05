extends Node

var highScore = 0
var save_path = "user://save_data.save"

func _ready():
	load_high_score()
	print(highScore)

func save_high_score():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file != null:
		file.store_var(highScore)
		file.close()

func load_high_score():
	# Always reset to 0 first as safe default
	highScore = 0
	
	# Check if file exists and is readable
	if not FileAccess.file_exists(save_path):
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	
	# Handle completely empty files (0 bytes)
	if file.get_length() == 0:
		file.close()
		return
	
	# Safe reading with validation
	var data = file.get_var()
	file.close()
	
	if typeof(data) == TYPE_INT:
		highScore = data
