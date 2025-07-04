extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		_on_btn_resume_pressed();
	pass

func _on_btn_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()  # Removes the menu from the scene
