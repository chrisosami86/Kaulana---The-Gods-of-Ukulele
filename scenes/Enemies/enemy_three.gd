extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var current_animation_state = animation_tree["parameters/playback"]
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var audio_attack: AudioStreamPlayer2D = $Audios/AudioAttack
@onready var audio_damage: AudioStreamPlayer2D = $Audios/AudioDamage
@onready var sfx_attack: AudioStreamPlayer2D = $Audios/SFXAttack
@onready var audio_die: AudioStreamPlayer2D = $Audios/AudioDie
@onready var sfx_rock: AudioStreamPlayer2D = $Audios/SFXRock
@onready var sfx_damage: AudioStreamPlayer2D = $Audios/SFXDamage


# ❤️ Sistema de vida
@export var max_health: int = 100
var current_health: int = max_health

# 🛡️ Sistema de invulnerabilidad
var is_invulnerable: bool = false
@export var invulnerability_time: float = 1.0  # Tiempo de inmunidad (ajustable)

@export var portion_scene: PackedScene
@export var rock_spike_scene: PackedScene
@export var move_speed: float = 100.0

var can_attack: bool = false  # ¿El jugador está en rango de ataque?
@export var cooldown_time: float = 2.0  # Tiempo entre ataques (ajustable)
var is_on_cooldown: bool = false  # ¿Está esperando para atacar de nuevo?

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
	current_health = max_health
	change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	match current_enemy_state:
		State.IDLE:
			# No moverse
			velocity.x = 0
		
		State.CHASE:
			# Moverse hacia el jugador
			if player != null:
				# ⚔️ NUEVO: Verificar si puede atacar
				if can_attack and not is_on_cooldown:
					# Está cerca Y no está en cooldown → ATACAR
					start_attack()
				else:
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
	
	flip_sprite(direction.x)
	
	# 🧪 Debug: ver la dirección
	print("Persiguiendo jugador. Dirección X: ", direction.x)

# 🔄 Voltear sprite según la dirección
func flip_sprite(direction_x: float) -> void:
	if direction_x > 0:
		# Moviendo a la derecha → sprite normal
		sprite_2d.flip_h = false
	elif direction_x < 0:
		# Moviendo a la izquierda → voltear sprite
		sprite_2d.flip_h = true
	# Si direction_x == 0 (no se mueve), no cambiamos nada

func start_attack():
	# 🔄 Voltear hacia el jugador antes de atacar
	if player != null:
		var direction = player.global_position.x - global_position.x
		flip_sprite(direction)
	change_state(State.ATTACK)
	audio_attack.play()
	sfx_attack.play()
	print("¡Iniciando ataque!")
	
func spawn_rock_spike() -> void:
	sfx_rock.play()
	if rock_spike_scene == null:
		push_error("¡No se asignó la escena de la roca en el Inspector!")
		return
		
		# Verificar que tengamos referencia al jugador
	if player == null:
		print("⚠️ No hay jugador para apuntar la roca")
		return
		
	var rock = rock_spike_scene.instantiate()
	var spawn_position = Vector2.ZERO
	
	var prediction_offset = 50  # Píxeles adelante
	var player_direction = sign(player.velocity.x)  # -1 izquierda, 1 derecha, 0 quieto
	
	spawn_position.x = player.global_position.x + (player_direction * prediction_offset)
	
	# 📍 Mantener la Y en el suelo (mismo nivel que el golem)
	spawn_position.y = global_position.y
	
	rock.global_position = spawn_position
	get_parent().add_child(rock)
	print("¡Roca spawneada!")


# ⏳ Iniciar cooldown después de atacar
func start_cooldown() -> void:
	change_state(State.COOLDOWN)
	is_on_cooldown = true
	
	# Iniciar el timer
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.start()
	
	print("Entrando en cooldown por ", cooldown_time, " segundos")
# 🎭 Función para cambiar de estado

# 💔 Recibir daño
func take_damage(damage: int) -> void:
	audio_damage.play()
	sfx_damage.play()
	# No recibir daño si ya está muerto
	if current_enemy_state == State.DEATH:
		return
	
	# 🛡️ No recibir daño si es invulnerable
	if is_invulnerable:
		print("⚔️ ¡Golem es invulnerable! Daño bloqueado")
		return
	
	# Reducir vida
	current_health -= damage
	current_health = max(current_health, 0)
	
	print("💔 ¡Golem recibió ", damage, " de daño! Vida: ", current_health, "/", max_health)
	
	# Verificar si murió
	if current_health <= 0:
		die()
	else:
		# Activar invulnerabilidad
		activate_invulnerability()
		# Mostrar animación de daño
		get_hurt()

# 🤕 Estado de recibir daño
func get_hurt() -> void:
	change_state(State.HURT)
	print("¡Golem herido!")

# 🛡️ Activar invulnerabilidad temporal
func activate_invulnerability() -> void:
	is_invulnerable = true
	invulnerability_timer.wait_time = invulnerability_time
	invulnerability_timer.start()
	# ✨ Iniciar parpadeo visual
	start_blink()
	print("🛡️ Invulnerabilidad activada por ", invulnerability_time, " segundos")


# ✨ Parpadeo visual durante invulnerabilidad
func start_blink() -> void:
	var sprite = $Sprite2D  # Ajusta según tu nodo
	
	# Parpadear cada 0.1 segundos
	var blink_duration = invulnerability_time
	var blink_interval = 0.1
	var elapsed = 0.0
	
	while elapsed < blink_duration:
		sprite.modulate.a = 0.3  # Semi-transparente
		await get_tree().create_timer(blink_interval).timeout
		sprite.modulate.a = 1.0  # Opaco
		await get_tree().create_timer(blink_interval).timeout
		elapsed += blink_interval * 2
	
	# Asegurar que termina opaco
	sprite.modulate.a = 1.0


# 💀 Morir
func die() -> void:
	audio_die.play()
	change_state(State.DEATH)
	print("¡Golem eliminado!")
	
	# Desactivar colisiones para que el jugador pueda pasar
	set_collision_layer_value(4, false)
	set_collision_mask_value(2, false)
	
		# 🛑 Desactivar TODAS las áreas de detección
	$DetectionArea.set_deferred("monitoring", false)
	$AttackRange.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitoring", false)
	
	# 🛑 Detener TODOS los timers
	cooldown_timer.stop()
	invulnerability_timer.stop()
	
	# 🛑 Resetear banderas de control
	can_attack = false
	is_on_cooldown = false
	player = null  # Olvidar referencia al jugador
	
	await get_tree().create_timer(1.5).timeout  # Ajusta según duración de tu animación
	# 💰 Soltar items (opcional)
	drop_loot()
	remove_from_scene()

# 🗑️ Eliminar el golem de la escena
func remove_from_scene() -> void:
	print("💀 Golem eliminado de la escena")
	queue_free()

# 💰 Soltar loot al morir
func drop_loot() -> void:
	var potion  = portion_scene.instantiate()
	potion.global_position = global_position + Vector2(0,30)
	get_parent().add_child(potion)
	print("💰 Loot dropped!")

# 🔄 Recuperarse del estado HURT
func recover_from_hurt() -> void:
	# Volver al estado apropiado según la situación
	if player != null and can_attack and not is_on_cooldown:
		start_attack()
	elif player != null:
		change_state(State.CHASE)
	else:
		change_state(State.IDLE)
	
	print("Recuperado del daño")


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
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	# Verificar que sea el jugador (por grupo o nombre)
	if body.is_in_group("player"):
		player = body  # Guardar referencia
		change_state(State.CHASE)  # Empezar a perseguirlo
		print("¡Jugador detectado! Iniciando persecución")
		


func _on_detecttion_area_body_exited(body: Node2D) -> void:
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	if body.is_in_group("player"):
		player = null  # Olvidar referencia
		change_state(State.IDLE)  # Volver a idle
		print("Jugador fuera de rango. Volviendo a IDLE")


func _on_attack_range_body_entered(body: Node2D) -> void:
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	if body.is_in_group("player"):
		can_attack = true  # Marcar que puede atacar
		print("¡Jugador en rango de ataque!")


func _on_attack_range_body_exited(body: Node2D) -> void:
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	if body.is_in_group("player"):
		can_attack = false  # Ya no puede atacar
		print("Jugador fuera de rango de ataque")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Verificar que sea un ataque del jugador
	if area.is_in_group("player"):
		# Obtener el daño del ataque (si tiene la propiedad)
		var damage = 10  # Daño por defecto
		
		# Si el ataque tiene una propiedad 'damage', usarla
		if area.has_method("get_damage"):
			damage = area.get_damage()
		elif "damage" in area:
			damage = area.damage
		
		take_damage(damage)


func _on_cooldown_timer_timeout() -> void:
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	is_on_cooldown = false
	print("¡Cooldown terminado!")
	
	# Si el jugador todavía está cerca, volver a perseguir
	if player != null and can_attack:
		# Si está en rango de ataque, atacar inmediatamente
		start_attack()
	elif player != null:
		# Si está en rango de detección pero no de ataque, perseguir
		change_state(State.CHASE)
	else:
		# Si no hay jugador cerca, volver a idle
		change_state(State.IDLE)


func _on_invulnerability_timer_timeout() -> void:
	if current_enemy_state == State.DEATH:  # ← Verificar primero
		return
	
	is_invulnerable = false
	print("✅ Invulnerabilidad terminada. Vulnerable de nuevo")
