extends Node2D

# Rect2 local (posición y tamaño) relativos al root de la sesión.
# Ajusta estos valores en el inspector por cada sesión.
@export var camera_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1024, 720))

# Devuelve los bounds en coordenadas globales (mundo)
func get_camera_bounds_global() -> Rect2:
	var top_left_global = global_position + camera_bounds.position
	return Rect2(top_left_global, camera_bounds.size)
