extends Node2D

@export var camera_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1024, 720))

func get_camera_bounds_global() -> Rect2:
	var top_left_global = global_position + camera_bounds.position
	return Rect2(top_left_global, camera_bounds.size)

# Esta función la conectaremos al Area2D (CameraTrigger)
func _on_camera_trigger_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		print("📸 Player detectado, actualizando límites de cámara...")
		var main = get_tree().get_first_node_in_group("main")
		if main:
			var cam = get_tree().get_first_node_in_group("player").get_node("Camera2D")
			main.set_camera_limits_from_rect(cam, get_camera_bounds_global())
