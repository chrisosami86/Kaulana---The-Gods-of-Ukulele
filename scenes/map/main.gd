extends Node2D

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var player: CharacterBody2D = $Player
@onready var session: Node2D = $CurrenLevel/Section3
@onready var curren_level: Node2D = $CurrenLevel

var is_transitioning = false

func _ready():
	fade_rect.modulate.a = 0.0
	var cam: Camera2D = player.get_node("Camera2D")
	var rect: Rect2 = session.get_camera_bounds_global()


func fade_to_black_and_change_scene(new_section_path: String, new_position: Vector2):
	if is_transitioning:
		return
	is_transitioning = true

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.2) # oscurece
	tween.tween_callback(Callable(self, "_change_section").bind(new_section_path, new_position))
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.2) # vuelve a aclarar
	tween.tween_callback(Callable(self, "_on_fade_done"))


func _change_section(new_section_path: String, new_position: Vector2):
	# eliminar la sección actual
	if curren_level.get_child_count() > 0:
		curren_level.get_child(0).queue_free()

	# cargar nueva sección
	var new_section_scene = load(new_section_path)
	var new_section = new_section_scene.instantiate()
	curren_level.add_child(new_section)

	# mover player
	player.global_position = new_position


func _on_fade_done():
	is_transitioning = false


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
