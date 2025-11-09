extends Area2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

var is_in_save_point = false
var is_saving = false

func _ready() -> void:
	state_machine.travel("save_idle")

func _physics_process(delta: float) -> void:
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
	"""
	var current = self
	var max_iterations = 20
	
	for i in range(max_iterations):
		if current == null:
			break
		
		# Verificar si es una sección
		if current.name.begins_with("Section"):
			return current.name
		
		# Subir al padre
		current = current.get_parent()
	
	return ""

func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = false
