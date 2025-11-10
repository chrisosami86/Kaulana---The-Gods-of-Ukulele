extends  CharacterBody2D

@export var move_speed: float
@export var jump_speed:float
@export var next_scene_path: String = "res://scenes/Control/game_over_screen.tscn"
var max_health = 3
var health = 3

#Referencia al nodo del area de ataque
@onready var collision_attack: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var collision_player: CollisionShape2D = $CollisionShape2D
@onready var collision_hurtbox: CollisionShape2D = $HurtBox/CollisionShape2D


#Referencia al nodo de animacion para poder
#ejecutar sus metodos como reproducir animación, etc
@onready var animated_sprite = $AnimatedSprite2D


#Bandera para verificar hacia donde esta mirando
#el personaje
var is_facing_right = true

#Referencia a al valor de la gravedad que trae
#el motor
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Banderas
var is_attacking = false
var is_crouched = false
var is_alive = true
var is_damaged = false

func _ready():
	add_to_group("player")
	
#Funcion para detectar cambios en las fisicas
#como velocidades, colisiones, etc
func _physics_process(delta: float) -> void:
	# 🛑 Si está muerto, solo aplicar gravedad y salir
	if not is_alive:
		velocity.y += gravity * delta
		velocity.x = 0  # No moverse horizontalmente
		update_animations()
		move_and_slide()
		return
	
	# 🛑 Si está dañado, no permitir acciones pero SÍ aplicar física
	if is_damaged:
		velocity.y += gravity * delta  # Gravedad normal
		# El knockback ya aplicó velocity.x, solo dejamos que se detenga naturalmente
		velocity.x = lerp(velocity.x, 0.0, 0.1)  # Fricción gradual
		update_animations()
		move_and_slide()
		return
	
	handle_attack()
	move_x()
	flip()
	jump(delta)
	get_down()
	update_animations()
	move_and_slide()


#Funcion para actualizar las animaciones
#del personaje
func update_animations():
		# 🎯 PRIORIDAD 1: Muerte (máxima prioridad)
	if not is_alive:
		animated_sprite.play("die")
		return
	
	# 🎯 PRIORIDAD 2: Daño
	if is_damaged:
		animated_sprite.play("damage")
		return
	
	# 🎯 PRIORIDAD 3: Ataque (no modificar velocity aquí)
	if is_attacking:
		return  # La animación ya se reproduce en handle_attack()
	
	# 🎯 PRIORIDAD 4: Agachado
	if is_crouched and is_on_floor():
		animated_sprite.play("crouched")
		return
	
	# 🎯 PRIORIDAD 5: En el aire
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return
	
	# 🎯 PRIORIDAD 6: Movimiento normal
	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

#funcion de ataque del personaje
func handle_attack():
	if not is_alive or is_damaged:
		return
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		velocity.x = 0  # ← Detener movimiento al atacar
		collision_attack.disabled = false
		
		if not is_on_floor():
			animated_sprite.play("jump-attack")
			collision_attack.position.y = -15
			
		elif is_on_floor() and is_crouched:
			animated_sprite.play("crouched-attack")
			collision_attack.position.y = 11
			
			collision_player.scale.y = 0.7
			collision_player.position.y = 16
			collision_hurtbox.scale.y = 0.7
			collision_hurtbox.position.y = 14
			
		else:
			animated_sprite.play("attack")
			velocity.x = 0
			collision_attack.position.y = -15

func get_down():
	if not is_alive or is_damaged:
		return
	if Input.is_action_pressed("crouched") and is_on_floor() and not is_attacking:
		velocity.x = 0
		is_crouched = true
		collision_player.scale.y = 0.7
		collision_player.position.y = 12.9
		collision_hurtbox.scale.y = 0.7
		collision_hurtbox.position.y = 14
	elif Input.is_action_pressed("crouched") and is_on_floor() and is_attacking:
		is_crouched = true
		velocity.x = 0
		collision_player.scale.y = 0.7
		collision_player.position.y = 12.9
		collision_hurtbox.scale.y = 0.7
		collision_hurtbox.position.y = 14
	else:
		is_crouched = false
		collision_player.scale.y = 1
		collision_player.position.y = 3.0
		collision_hurtbox.position.y = 3.0
		collision_hurtbox.scale.y = 1

#Funcion de recibir daño
# Funcion de recibir daño
func take_damage(amount: int):
	# 🛡️ No recibir daño si ya está muerto o ya está siendo dañado
	if not is_alive or is_damaged:
		return
	
	is_damaged = true
	health -= amount
	
	if health < 0:
		health = 0

	get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
	
	# 💨 Knockback (retroceso) al recibir daño
	apply_knockback()

# 💨 Retroceso al recibir daño
func apply_knockback():
	var knockback_force = 150.0  # Ajustable
	var knockback_direction = -1 if is_facing_right else 1  # Retrocede en dirección opuesta
	
	# Aplicar retroceso horizontal
	velocity.x = knockback_direction * knockback_force
	
	# 🛑 Detener ataque si estaba atacando
	if is_attacking:
		is_attacking = false
		collision_attack.set_deferred("disabled", true)
	if health <= 0:
		die()
	else:
		# ⏱️ Timer de seguridad: si la animación no termina, forzar recuperación
		await get_tree().create_timer(0.5).timeout
		if is_damaged:  # Si todavía está en damaged después de 0.5s
			is_damaged = false
			print("⚠️ Recuperación forzada de daño")

func die():
	is_alive = false
	is_damaged = false  # ← Limpiar bandera de daño
	is_attacking = false  # ← Limpiar bandera de ataque
	is_crouched = false  # ← Limpiar bandera de agachado
	
	velocity.x = 0
	velocity.y = 0  # ← Detener movimiento vertical también
	
	# Desactivar colisiones
	set_collision_layer_value(2, false)
	set_collision_mask_value(4, false)
	
	# Desactivar hitboxes
	collision_attack.set_deferred("disabled", true)
	collision_hurtbox.set_deferred("monitoring", false)  # ← No recibir más daño
	
	print("💀 Jugador ha muerto")
	GameState.reset_save()
	
	
#Funcion de movimiento del personaje
func move_x():
	if not is_alive or is_damaged or is_attacking:
		return
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

#Funcion para rotar el nodo del personaje
#segun su direccion
func flip():
	if not is_alive or is_damaged:
		return
	if is_on_floor() and is_attacking:
		return
	var input_axis = Input.get_axis("move_left","move_right")
	velocity.x = input_axis * move_speed
	

#Funcion de Salto
func jump(delta):
	if not is_alive or is_damaged:
		return
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = -jump_speed
	if not is_on_floor():
		velocity.y += gravity * delta

#Funcion que emite que recibe una señal
#cuando termina una animacion
func _on_animated_sprite_2d_animation_finished() -> void:
		# 🛑 Si está muerto, solo manejar animación de muerte
	if not is_alive:
		if animated_sprite.animation == 'die':
			queue_free()
			get_tree().change_scene_to_file(next_scene_path)
		return
	
	# ⚔️ Fin de ataque
	if animated_sprite.animation in ["attack", "jump-attack", "crouched-attack"]:
		is_attacking = false
		collision_attack.disabled = true
	
	# 💔 Fin de animación de daño
	if animated_sprite.animation == 'damage':
		is_damaged = false
		print("✅ Recuperado de daño")


func _on_hurt_box_body_entered(body: Node2D) -> void:
	# 🛑 No procesar si está muerto
	if not is_alive:
		return
	
	if body.is_in_group('i_heart'):
		if health < max_health:  # ← Usar max_health en lugar de 3
			health += 1
			get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
			body.queue_free()
		else:
			body.queue_free()
	
	if body.is_in_group('enemies'):
		take_damage(1)




func _on_hurt_box_area_entered(area: Area2D) -> void:
	# 🛑 No procesar si está muerto
	if not is_alive:
		return
	
	if area.is_in_group("save_point"):
		health = max_health  # ← Usar max_health en lugar de 3
		get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
	
	if area.name == "SpikeArea":
		take_damage(1)
	
	if area.is_in_group('projectiles'):
		take_damage(1)
