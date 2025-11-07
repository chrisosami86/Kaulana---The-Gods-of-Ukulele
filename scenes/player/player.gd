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
	if is_damaged:
		velocity.x = 0
		animated_sprite.play("damage")
		return
	
	if not is_alive:
		animated_sprite.play("die")
		return
		
	if is_attacking:
		if is_on_floor():
			velocity.x = 0
		return
	
	
	
	if is_crouched and is_on_floor():
		animated_sprite.play("crouched")
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return
	
	
		

		
	if velocity.x != 0:
		animated_sprite.play("run")
	else :
		animated_sprite.play("idle")

#funcion de ataque del personaje
func handle_attack():
	if not is_alive or is_damaged:
		return
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
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
			
		else :
			animated_sprite.play("attack")
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
func take_damage(amount: int):
	is_damaged = true
	health -= amount
	
	if health < 0:
		health = 0

	get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
		
	if health <= 0:
		velocity.y += gravity
		die()

func die():
	is_alive = false
	velocity.x= 0
	set_collision_layer_value(2, false)
	set_collision_mask_value(4, false)
	#set_process(false)
	
	
#Funcion de movimiento del personaje
func move_x():
	if not is_alive or is_damaged:
		return
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

#Funcion para rotar el nodo del personaje
#segun su direccion
func flip():
	if not is_alive or is_damaged:
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
	if animated_sprite.animation == "attack" or animated_sprite.animation == "jump-attack" or animated_sprite.animation == "crouched-attack":
		is_attacking = false
		collision_attack.disabled = true
	
		
	if animated_sprite.animation == 'die':
		queue_free()
		get_tree().change_scene_to_file(next_scene_path)
	
	if animated_sprite.animation == 'damage':
		is_damaged = false


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group('i_heart'):
		if health < 3:
			health += 1
			get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
			body.queue_free()
		else :
			body.queue_free()
			
	if body.is_in_group('enemies'):
		take_damage(1)




func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("save_point"):
		health = 3
		get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
	
	if area.name == "SpikeArea":
		take_damage(1)
