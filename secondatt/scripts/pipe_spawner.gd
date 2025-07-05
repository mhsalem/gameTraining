extends Node2D

const pipePairScene = preload("res://scenes/pipePair.tscn")




# start it off to the right:


func _on_timer_timeout() -> void:
	var pipe = pipePairScene.instantiate()
	add_child(pipe)
	pipe.position.x = get_viewport().size.x + 5
	pass # Replace with function body.
