class_name SavePoint

extends Area2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

var is_in_save_point = false
var is_saving = false

func _ready() -> void:
	state_machine.travel("save_idle")

func _physics_process(_delta: float) -> void:
	saveGame()

func saveGame():
	if not is_in_save_point:
		return
	
	if Input.is_action_just_pressed("move_up") and not is_saving:
		is_saving = true
		state_machine.travel("save_ok")
		
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			push_error("❌ No se encontró el jugador")
			is_saving = false
			return
		
		# 🔍 Buscar el nodo Section de forma robusta
		var section_name = _find_section_name()
		
		if section_name == "":
			push_error("❌ No se encontró nodo Section válido")
			is_saving = false
			return
		
		# 💾 Guardar checkpoint
		GameState.set_checkpoint(section_name, player.global_position)
		
		# Debug
		print("💾 Guardado exitoso:")
		print("   Sección:", GameState.get_checkpoint_section())
		print("   Posición:", GameState.get_checkpoint_position())
		
		await get_tree().create_timer(2.64).timeout
		state_machine.travel("save_idle")
		is_saving = false

# 🔍 Función auxiliar para encontrar la sección
func _find_section_name() -> String:
	"""
	Busca el nodo Section subiendo en el árbol.
	Retorna el nombre de la sección o "" si no la encuentra.
	"""
	var current = self
	var max_iterations = 20
	
	for i in range(max_iterations):
		if current == null:
			break
		
		print("🔍 Revisando:", current.name, "| Clase:", current.get_class())
		
		# 🔑 BUSCAR POR MÚLTIPLES CRITERIOS
		var node_name = current.name
		
		# Verificar si empieza con "Section" (mayúscula)
		if node_name.begins_with("Section"):
			print("   ✅ Sección encontrada:", node_name)
			return node_name
		
		# 🆕 TAMBIÉN buscar por nombres de archivo (minúsculas)
		if node_name.begins_with("section"):
			# Convertir "section three" → "Section3"
			var mapped_name = _map_file_name_to_section_name(node_name)
			print("   ✅ Sección encontrada (mapeada):", node_name, "→", mapped_name)
			return mapped_name
		
		# Subir al padre
		current = current.get_parent()
	
	push_error("❌ No se encontró nodo Section en el árbol")
	return ""

# 🗺️ Mapeo de nombres de archivo a nombres de sección
func _map_file_name_to_section_name(file_name: String) -> String:
	"""
	Convierte nombres como "section three" a "Section3".
	"""
	var mapping = {
		"section one": "Section1",
		"section two": "Section2",
		"section three": "Section3",
		"section four": "Section4",
		"section five": "Section5",
	}
	
	# Normalizar (quitar espacios extras, convertir a minúsculas)
	var normalized = file_name.strip_edges().to_lower()
	
	return mapping.get(normalized, "")

func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = false
