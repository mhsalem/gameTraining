extends Area2D
@onready var game_manager: Node = %GameManager
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D




func _on_body_entered(body: Node2D) -> void:
	print("oy gl")
	game_manager.add_point()
	
	$AnimationPlayer.play("pickUp_animation")
