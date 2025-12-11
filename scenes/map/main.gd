extends Node2D

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var player: CharacterBody2D = $Player
@onready var curren_level: Node2D = $CurrentLevel


var is_transitioning = false

func _ready():
	fade_rect.modulate.a = 0.0
	
	# Esperar un frame para que todo esté inicializado
	await get_tree().process_frame
	
	# 🛑 Verificar si estamos cargando partida guardada
	if GameState.is_loading_from_save:
		print("⏳ Main: Cargando partida guardada (GameState se encarga)")
		return  # GameState ya instanciará la sección correcta
	
	# ✅ Nueva partida: cargar Section1 por defecto
	print("🆕 Main: Nueva partida - Cargando Section1")
	_load_initial_section()

func _load_initial_section():
	"""
	Carga Section1 para nueva partida.
	"""
	# Limpiar cualquier sección existente
	for child in curren_level.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# Cargar Section1
	var section1_path = "res://scenes/map/area_tutorial/sections/Section1.tscn"
	var section1_scene = load(section1_path)
	
	if not section1_scene:
		push_error("❌ No se pudo cargar Section1")
		return
	
	var section1 = section1_scene.instantiate()
	
	# 🔑 CRÍTICO: Forzar el nombre a "Section1"
	section1.name = "Section1"
	
	curren_level.add_child(section1)
	
	print("✅ Section1 cargada con nombre:", section1.name)
	
	# Configurar cámara para Section1
	_setup_camera_for_section(section1)

func _setup_camera_for_section(section: Node2D):
	"""
	Configura los límites de la cámara para una sección.
	"""
	if not section.has_method("get_camera_bounds_global"):
		push_warning("⚠️ La sección no tiene método get_camera_bounds_global")
		return
	
	var cam: Camera2D = player.get_node_or_null("Camera2D")
	if not cam:
		push_error("❌ No se encontró Camera2D en el jugador")
		return
	
	var rect: Rect2 = section.get_camera_bounds_global()
	set_camera_limits_from_rect(cam, rect)
	
	print("📷 Cámara configurada para sección:", section.name)

func fade_to_black_and_change_scene(new_section_path: String, new_position: Vector2):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.2)
	tween.tween_callback(Callable(self, "_change_section").bind(new_section_path, new_position))
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.2)
	tween.tween_callback(Callable(self, "_on_fade_done"))

func _change_section(new_section_path: String, new_position: Vector2):
	"""
	Cambia a una nueva sección (usado por transiciones durante el juego).
	"""
	# Eliminar la sección actual
	if curren_level.get_child_count() > 0:
		curren_level.get_child(0).queue_free()
	
	await get_tree().process_frame
	
	# Cargar nueva sección
	var new_section_scene = load(new_section_path)
	if not new_section_scene:
		push_error("❌ No se pudo cargar:", new_section_path)
		return
	
	var new_section = new_section_scene.instantiate()
	
	# 🔑 MAPEO INVERSO: de path a nombre
	var section_name = _get_section_name_from_path(new_section_path)
	new_section.name = section_name
	
	curren_level.add_child(new_section)
	
	# Mover player
	player.global_position = new_position
	
	# Configurar cámara
	_setup_camera_for_section(new_section)
	
	print("✅ Transición completada a:", section_name)

# 🗺️ Función auxiliar para obtener el nombre correcto
func _get_section_name_from_path(path: String) -> String:
	"""
	Convierte la ruta del archivo al nombre de sección correcto.
	"""
	var path_to_name = {
		"res://scenes/map/area_tutorial/sections/Section1.tscn": "Section1",
		"res://scenes/map/area_tutorial/sections/Section2.tscn": "Section2",
		"res://scenes/map/area_tutorial/sections/Section3.tscn": "Section3",
		"res://scenes/map/area_tutorial/sections/Section4.tscn": "Section4",
		"res://scenes/map/area_tutorial/sections/Section5.tscn": "Section5",
	}
	
	return path_to_name.get(path, "Section1")  # Default a Section1 si no encuentra

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
