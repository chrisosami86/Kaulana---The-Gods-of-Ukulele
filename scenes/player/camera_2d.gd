extends Camera2D

func set_camera_limits_from_rect(cam: Camera2D, rect: Rect2) -> void:
	# Tamaño de la pantalla en píxeles
	var screen_px_size: Vector2 = get_viewport().get_visible_rect().size
	# Tamaño del área del mundo que la cámara ve (teniendo en cuenta zoom)
	var world_view_size: Vector2 = screen_px_size * cam.zoom

	# X axis
	if rect.size.x <= world_view_size.x:
		var extra_x = world_view_size.x - rect.size.x
		cam.limit_left  = int(rect.position.x - extra_x * 0.5)
		cam.limit_right = int(rect.position.x + rect.size.x + extra_x * 0.5)
	else:
		cam.limit_left  = int(rect.position.x)
		cam.limit_right = int(rect.position.x + rect.size.x)

	# Y axis
	if rect.size.y <= world_view_size.y:
		var extra_y = world_view_size.y - rect.size.y
		cam.limit_top    = int(rect.position.y - extra_y * 0.5)
		cam.limit_bottom = int(rect.position.y + rect.size.y + extra_y * 0.5)
	else:
		cam.limit_top    = int(rect.position.y)
		cam.limit_bottom = int(rect.position.y + rect.size.y)
