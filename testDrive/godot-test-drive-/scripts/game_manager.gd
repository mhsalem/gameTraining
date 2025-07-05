extends Node
var score = 0

# Define a signal
signal score_updated(new_score)

func add_point():
	score += 1
	print(score)
	# Emit the signal with the new score value
	score_updated.emit(score)
