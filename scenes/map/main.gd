extends Node2D


func _ready():
	var player = $Player      # o el nombre exacto de tu nodo Player
	var session = $CurrenLevel/Section1 # o el nombre exacto de tu nodo SessionOne

	var cam: Camera2D = player.get_node("Camera2D")
	var rect: Rect2 = session.get_camera_bounds_global()

	set_camera_limits_from_rect(cam, rect)

func set_camera_limits_from_rect(cam: Camera2D, rect: Rect2) -> void:
	var screen_px_size: Vector2 = get_viewport().get_visible_rect().size
	var world_view_size: Vector2 = screen_px_size * cam.zoom

	if rect.size.x <= world_view_size.x:
		var extra_x = world_view_size.x - rect.size.x
		cam.limit_left  = int(rect.position.x - extra_x * 0.5)
		cam.limit_right = int(rect.position.x + rect.size.x + extra_x * 0.5)
	else:
		cam.limit_left  = int(rect.position.x)
		cam.limit_right = int(rect.position.x + rect.size.x)

	if rect.size.y <= world_view_size.y:
		var extra_y = world_view_size.y - rect.size.y
		cam.limit_top    = int(rect.position.y - extra_y * 0.5)
		cam.limit_bottom = int(rect.position.y + rect.size.y + extra_y * 0.5)
	else:
		cam.limit_top    = int(rect.position.y)
		cam.limit_bottom = int(rect.position.y + rect.size.y)
