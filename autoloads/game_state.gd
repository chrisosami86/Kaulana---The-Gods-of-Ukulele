extends Node

var is_dialogue_active = false
# Ruta del archivo de guardado (usaremos user://)
#var save_file_path: String = "res://save_data/savegame.json"
var save_file_path: String = "user://savegame.json"

# 🚩 Flag para indicar si estamos cargando una partida guardada
var is_loading_from_save: bool = false

# Estructura en memoria
var save_data = {
	"version": 1,
	"current_section": "",
	"player_position": Vector2.ZERO,
	"tutorials_shown": {
		"attack": false,
		"crouched": false,
		"jump": false,
		"run": false,
		"health": false,
		"die": false,
		"save": false
			}
}

# ---------- Inicialización ----------
func _ready() -> void:
	# aquí podrías llamar load_from_disk() si quieres cargar automáticamente
	pass

# ---------- Operaciones sobre los tutoriales ----------
@warning_ignore("shadowed_variable_base_class")
func mark_tutorial_shown(name: String) -> void:
	"""
    Marca el tutorial 'name' como visto en save_data.
    No escribe a disco aquí (decide si guardar automáticamente o en checkpoints).
	"""
	save_data["tutorials_shown"][name] = true
	
	
@warning_ignore("shadowed_variable_base_class")
func should_show_tutorial(name: String) -> bool:
	"""
		Si el valor es false, el tutorial NO ha sido mostrado (es decir: hay que mostrarlo).
	"""
	return save_data["tutorials_shown"][name]

# ---------- Checkpoint (escena + posición) ----------
func set_checkpoint(section_name: String, player_position: Vector2) -> void:
	"""
	Guarda el checkpoint con validación.
	"""
	# 🛡️ Validación del nombre
	if section_name == "" or not section_name.begins_with("Section"):
		push_error("❌ Nombre de sección inválido:", section_name)
		return
	
	save_data["current_section"] = section_name
	save_data["player_position"] = player_position
	save_to_disk()
	
	print("✅ Checkpoint guardado:", section_name)

func get_checkpoint_section() -> String:
	return save_data.get("current_section", "")


func get_checkpoint_position() -> Vector2:
	return save_data["player_position"]

func _set_player_position(position: Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = position

func load_game() -> void:
	"""
	Carga la partida y cambia a Main.tscn con la sección correcta.
	"""
	# Intentar cargar desde disco
	if not load_from_disk():
		push_error("❌ No se pudo cargar la partida")
		return
	
	# Obtener la sección guardada
	var section_name = get_checkpoint_section()
	
	# Validar que haya una sección guardada
	if section_name == "" or section_name == null:
		push_warning("⚠️ No hay checkpoint guardado. Iniciando nueva partida.")
		get_tree().change_scene_to_file("res://scenes/map/main.tscn")
		return
	
	print("🎮 Cargando partida guardada:")
	print("   Sección:", section_name)
	print("   Posición:", get_checkpoint_position())
	
	# 🚩 ACTIVAR FLAG antes de cambiar de escena
	is_loading_from_save = true
	
	# Cambiar a Main.tscn
	get_tree().call_deferred("change_scene_to_file", "res://scenes/map/main.tscn")
	
	# Esperar a que Main se cargue
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Instanciar la sección correcta
	_load_section(section_name)
	
	# Esperar a que la sección y el jugador se instancien
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Posicionar al jugador
	_set_player_position(get_checkpoint_position())
	
	# 🚩 DESACTIVAR FLAG después de cargar
	is_loading_from_save = false

func _load_section(section_name: String) -> void:
	"""
	Instancia la sección indicada en CurrentLevel.
	"""
	var main = get_tree().current_scene
	if not main:
		push_error("❌ No se encontró Main")
		return
	
	var current_level = main.get_node_or_null("CurrentLevel")
	if not current_level:
		push_error("❌ No se encontró CurrentLevel")
		return
	
	# Limpiar secciones anteriores
	for child in current_level.get_children():
		print("🗑️ Eliminando:", child.name)
		child.queue_free()
	
	await get_tree().process_frame
	
	# Mapeo de secciones
	var section_paths = {
		"Section1": "res://scenes/map/area_tutorial/sections/Section1.tscn",
		"Section2": "res://scenes/map/area_tutorial/sections/Section2.tscn",
		"Section3": "res://scenes/map/area_tutorial/sections/Section3.tscn",
		"Section4": "res://scenes/map/area_tutorial/sections/Section4.tscn",
		"Section5": "res://scenes/map/area_tutorial/sections/Section5.tscn",
	}
	
	var section_path = section_paths.get(section_name, "")
	if section_path == "":
		push_error("❌ No existe path para:", section_name)
		print("   Secciones disponibles:", section_paths.keys())
		return
	
	var section_scene = load(section_path)
	if not section_scene:
		push_error("❌ No se pudo cargar:", section_path)
		return
	
	var section_instance = section_scene.instantiate()
	
	# 🔑 CRÍTICO: Forzar el nombre ANTES de agregar
	section_instance.name = section_name
	
	current_level.add_child(section_instance)
	
	print("✅ Sección instanciada:", section_instance.name)
	#print("   Verificación - Nombre real:", current_level.get_child(0).name if current_level.get_child_count() > 0 else "N/A")
	
	# 📷 Configurar cámara
	await get_tree().process_frame
	
	if main.has_method("_setup_camera_for_section"):
		main._setup_camera_for_section(section_instance)
	else:
		push_warning("⚠️ Main no tiene método _setup_camera_for_section")
	
# ---------- Guardar / Cargar (implementación posterior) ----------
func save_to_disk() -> void:
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo de guardado")
		return
	
	var data_to_save = save_data.duplicate(true)
	var raw_pos = save_data.get("player_position", Vector2.ZERO)
	
	if typeof(raw_pos) == TYPE_VECTOR2:
		data_to_save["player_position"] = {"x": raw_pos.x, "y": raw_pos.y}
	else:
		data_to_save["player_position"] = {"x": 0.0, "y": 0.0}
	
	var json_text = JSON.stringify(data_to_save, "\t")
	file.store_string(json_text)
	file.close()
	
	print("✅ Partida guardada:", data_to_save.get("current_section"))

func load_from_disk() -> bool:
	"""
	Lee el archivo y lo carga en save_data si existe y es válido.
	Maneja varios formatos históricos del campo player_position.
	"""
	# Verificar si el archivo existe
	if not FileAccess.file_exists(save_file_path):
		push_warning("⚠️ No existe archivo de guardado en: " + save_file_path)
		return false
	
	# Abrir archivo en modo lectura
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		push_error("❌ No se pudo abrir el archivo: " + save_file_path)
		return false
	
	# Leer contenido
	var json_text = file.get_as_text()
	file.close()
	
	# Parsear JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("❌ Error al parsear JSON: " + json.get_error_message())
		return false
	
	var loaded_data = json.data
	
	# Validar que sea un diccionario
	if typeof(loaded_data) != TYPE_DICTIONARY:
		push_error("❌ El archivo no contiene un diccionario válido")
		return false
	
	# Cargar los datos
	save_data = loaded_data
	
	# 🔧 Convertir player_position de {x, y} a Vector2
	var pos_data = save_data.get("player_position", {"x": 0, "y": 0})
	
	if typeof(pos_data) == TYPE_DICTIONARY:
		# Formato {x: valor, y: valor}
		save_data["player_position"] = Vector2(
			pos_data.get("x", 0.0),
			pos_data.get("y", 0.0)
		)
	elif typeof(pos_data) == TYPE_VECTOR2:
		# Ya es Vector2 (no debería pasar, pero por si acaso)
		save_data["player_position"] = pos_data
	else:
		# Formato desconocido, usar Vector2.ZERO
		save_data["player_position"] = Vector2.ZERO
	
	print("✅ Partida cargada correctamente desde:", save_file_path)
	print("   Escena:", save_data.get("scene_path", "N/A"))
	print("   Posición:", save_data["player_position"])
	
	return true


func reset_save() -> void:
	save_data = {
		"version": 1,
		"current_section": "",  # ← Cambio
		"player_position": Vector2.ZERO,
		"tutorials_shown": {
			"attack": false,
			"crouched": false,
			"jump": false,
			"run": false,
			"health": false,
			"die": false,
			"save": false
		}
	}
