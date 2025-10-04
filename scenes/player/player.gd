extends  CharacterBody2D

@export var move_speed: float
@export var jump_speed:float
@export var next_scene_path: String = "res://scenes/Control/game_over_screen.tscn"
var max_health = 3
var health = 3
@onready var collision_shape_2d: CollisionShape2D = $AttackHitbox/CollisionShape2D

#Referencia al nodo de animacion para poder
#ejecutar sus metodos como reproducir animación, etc
@onready var animated_sprite = $AnimatedSprite2D


#Bandera para verificar hacia donde esta mirando
#el personaje
var is_facing_right = true

#Referencia a al valor de la gravedad que trae
#el motor
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Bandera para verificar la acción de atacar
var is_attacking = false

func _ready():
	add_to_group("player")
	
#Funcion para detectar cambios en las fisicas
#como velocidades, colisiones, etc
func _physics_process(delta: float) -> void:
	handle_attack()
	move_x()
	flip()
	jump(delta)
	update_animations()
	move_and_slide()


#Funcion para actualizar las animaciones
#del personaje
func update_animations():
	if is_attacking:
		if is_on_floor():
			velocity.x = 0
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return

		
	if velocity.x:
		animated_sprite.play("run")
	else :
		animated_sprite.play("idle")

#funcion de ataque del personaje
#aun no cuenta con hitbox
func handle_attack():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		if not is_on_floor():
			is_attacking = true
			collision_shape_2d.disabled = false
			animated_sprite.play("jump-attack")
		else :
			is_attacking = true
			collision_shape_2d.disabled = false
			animated_sprite.play("attack")

#Funcion de recibir daño
func take_damage(amount: int):
	health -= amount
	if health < 0:
		health = 0
	get_tree().current_scene.get_node("HUD").update_hearts(health, max_health)
	
	if health == 0:
		die()

func die():
	#animated_sprite.play("death")
	queue_free()
	#set_process(false)
	get_tree().change_scene_to_file(next_scene_path)
	
#Funcion de movimiento del personaje
func move_x():
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

#Funcion para rotar el nodo del personaje
#segun su direccion
func flip():
	var input_axis = Input.get_axis("move_left","move_right")
	velocity.x = input_axis * move_speed
	

#Funcion de Salto
func jump(delta):
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = -jump_speed
	if not is_on_floor():
		velocity.y += gravity * delta

#Funcion que emite que recibe una señal
#cuando termina una animacion
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack" or animated_sprite.animation == "jump-attack":
		is_attacking = false
		collision_shape_2d.disabled = true
