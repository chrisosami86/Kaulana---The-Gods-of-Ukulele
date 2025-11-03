extends Node

# Ruta del archivo de guardado (usaremos user://)
var save_file_path: String = "user://savegame.json"

# Estructura en memoria
var save_data = {
	"version": 1,
	"scene_path": "",
	"player_position": Vector2.ZERO,
	"tutorials_shown": {
		"attack": false,
		"crounched": false,
		"jump": false,
		"health": false,
		"die": false
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
		Devuelve true si el tutorial NO ha sido mostrado (es decir: hay que mostrarlo).
	"""
	return not (name in save_data["tutorials_shown"] and save_data["tutorials_shown"][name] == true)

# ---------- Checkpoint (escena + posición) ----------
func set_checkpoint(scene_path: String, player_position: Vector2) -> void:
	"""
    Actualiza el checkpoint en memoria. Opcionalmente llamar save_to_disk() después.
	"""
	save_data["scene_path"] = scene_path
	save_data["player_position"] = player_position

func get_checkpoint_scene() -> String:
	return save_data["scene_path"]

func get_checkpoint_position() -> Vector2:
	return save_data["player_position"]

# ---------- Guardar / Cargar (implementación posterior) ----------
func save_to_disk() -> void:
	"""
    Escribe save_data a disk (user://savegame.json).
    Implementar con FileAccess + JSON en el momento que quieras.
	"""
	pass

func load_from_disk() -> void:
	"""
    Lee el archivo y lo carga en save_data si existe y es válido.
    Implementar con FileAccess + JSON; manejar versiones y fallos.
	"""
	pass

func reset_save() -> void:
	"""
    Pone save_data con valores por defecto (nuevo juego).
	"""
	save_data = {
		"version": 1,
		"scene_path": "",
		"player_position": Vector2.ZERO,
		"tutorials_shown": {}
	}

func saveData():
	print('Partida guardada con exito')
