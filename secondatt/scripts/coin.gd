extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "bird":
		get_tree().get_root().get_node("game").increase_score()
		queue_free()
