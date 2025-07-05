extends Label

func _ready():
	# Connect to the signal
	%GameManager.score_updated.connect(_on_score_updated)
	
	# Set initial score display
	text = "Score: " + str(%GameManager.score)

func _on_score_updated(new_score: int):
	text = "Score: " + str(new_score)
	
