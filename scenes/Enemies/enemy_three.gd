extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var current_animation_state = animation_tree["parameters/playback"]
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


@export var rock_spike_scene: PackedScene
@export var move_speed: float = 100.0

var player: CharacterBody2D = null


enum State {
	IDLE,      # Parado, esperando
	CHASE,     # Persiguiendo al jugador
	ATTACK,    # Ejecutando ataque
	COOLDOWN,  # Esperando para atacar de nuevo
	HURT,      # Recibiendo daño
	DEATH      # Muerto
}

var current_enemy_state: State = State.IDLE

func _ready() -> void:
	change_state(State.IDLE)
	

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_enemy_state:
		State.IDLE:
			# No moverse
			velocity.x = 0
		
		State.CHASE:
			# Moverse hacia el jugador
			if player != null:  # Verificar que tengamos referencia al jugador
				chase_player()
			else:
				# Si perdimos la referencia, volver a IDLE
				change_state(State.IDLE)
		
		State.ATTACK:
			# No moverse durante el ataque
			velocity.x = 0
		
		State.COOLDOWN:
			# No moverse durante cooldown
			velocity.x = 0
		
		State.HURT:
			# No moverse al recibir daño
			velocity.x = 0
		
		State.DEATH:
			# No moverse si está muerto
			velocity.x = 0
			
	move_and_slide()

func chase_player():
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Aplicar velocidad horizontal (solo en X)
	velocity.x = direction.x * move_speed
	
	# 🧪 Debug: ver la dirección
	print("Persiguiendo jugador. Dirección X: ", direction.x)

func spawn_rock_spike() -> void:
	if rock_spike_scene == null:
		push_error("¡No se asignó la escena de la roca en el Inspector!")
		return
	
	var rock = rock_spike_scene.instantiate()
	var spawn_position = global_position
	rock.global_position = spawn_position
	get_parent().add_child(rock)
	print("¡Roca spawneada!")

# 🎭 Función para cambiar de estado
func change_state(new_state: State) -> void:
	# Guardar el estado anterior (útil para debug)
	var old_state = current_enemy_state
	
	# Cambiar el estado de lógica
	current_enemy_state = new_state
	
	# Cambiar la animación correspondiente
	match new_state:
		State.IDLE:
			current_animation_state.travel("idle")
		
		State.CHASE:
			current_animation_state.travel("walk")
		
		State.ATTACK:
			current_animation_state.travel("attack")
		
		State.COOLDOWN:
			current_animation_state.travel("idle")  # Visualmente idle, pero lógicamente en cooldown
		
		State.HURT:
			current_animation_state.travel("damage")
		
		State.DEATH:
			current_animation_state.travel("die")
	
	# 🧪 Debug: ver los cambios de estado
	print("Estado cambiado: ", State.keys()[old_state], " → ", State.keys()[new_state])


func _on_detecttion_area_body_entered(body: Node2D) -> void:
	# Verificar que sea el jugador (por grupo o nombre)
	if body.is_in_group("player"):
		player = body  # Guardar referencia
		change_state(State.CHASE)  # Empezar a perseguirlo
		print("¡Jugador detectado! Iniciando persecución")
		


func _on_detecttion_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null  # Olvidar referencia
		change_state(State.IDLE)  # Volver a idle
		print("Jugador fuera de rango. Volviendo a IDLE")


func _on_attack_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_attack_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
