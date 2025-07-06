extends Control

func _draw() -> void:
	var ui = get_parent()
	if not ui or not ui.has_method("get_connection_data"):
		return
	
	var connections = ui.get_connection_data()
	for connection in connections:
		# Draw straight lines instead of bezier
		draw_line(
			connection.start_pos,
			connection.end_pos,
			connection.color,
			connection.width
		)

		# Draw arrowhead at the end
		var direction = (connection.end_pos - connection.start_pos).normalized()
		var arrow_size = 8
		var arrow_point1 = connection.end_pos - direction.rotated(PI/4) * arrow_size
		var arrow_point2 = connection.end_pos - direction.rotated(-PI/4) * arrow_size
		draw_line(connection.end_pos, arrow_point1, connection.color, connection.width)
		draw_line(connection.end_pos, arrow_point2, connection.color, connection.width)
