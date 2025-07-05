extends Node2D


var score = 0

@onready var label: Label = $Label

func increase_score():
	score += 1
	if score>Global.highScore:
		Global.highScore=score   
	Global.save_high_score()
	if score%20<10:
		$TileMapNight.visible=false
		$TileMapDay.visible=true
	else:
		$TileMapNight.visible=true
		$TileMapDay.visible=false
		
	label.text = "Score: %d" % score + " high score: %d" %Global.highScore
