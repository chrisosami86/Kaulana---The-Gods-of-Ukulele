extends CharacterBody2D

@export var speed: float = 50.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = -1
var health = 2
var is_damaged = false
var is_dead = false
var can_move: bool = true

@onready var wall_ray_left: RayCast2D = $WallRayLeft
@onready var wall_ray_right: RayCast2D = $WallRayRight
@onready var ground_ray_left: RayCast2D = $GroundRayLeft
@onready var ground_ray_right: RayCast2D = $GroundRayRight
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var idle_timer: Timer = $IdleTimer

func _ready() -> void:
	state_machine.travel('run')
	velocity.x = speed * direction
	update_sprite_direction()

func _physics_process(_delta: float) -> void:
	if can_move and not is_damaged and not is_dead:
		move()
	
	velocity.y = gravity
	move_and_slide()

func move():
	if not can_move:
		return
	
	var should_turn = false
	
	if direction == -1:
		if wall_ray_left.is_colliding() or not ground_ray_left.is_colliding():
			should_turn = true
	else:
		if wall_ray_right.is_colliding() or not ground_ray_right.is_colliding():
			should_turn = true
	
	if should_turn:
		direction *= -1
		velocity.x = speed * direction
		update_sprite_direction()

func update_sprite_direction():
	"""
	Solo voltea el sprite, NO el nodo completo.
	"""
	sprite.flip_h = (direction == 1)

func take_damage():	
	if state_machine.get_current_node() == 'die':
		return
	
	is_damaged = true
	state_machine.travel('damage')
	health -= 1
	velocity.x = 0
	
	await get_tree().create_timer(0.4).timeout
	
	if health <= 0:
		is_dead = true
		die()
	else:
		is_damaged = false
		state_machine.travel('run')
		velocity.x = speed * direction

func die():
	is_dead = true
	state_machine.travel('die')
	velocity.x = 0
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(0.5).timeout
	queue_free()

# 🆕 Detectar cuándo toca al jugador (sin causar daño)
func _on_contact_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_move and not is_damaged and not is_dead:
		print("🦀 Cangrejo tocó al jugador")
		
		# Calcular en qué lado está el jugador
		var player_direction = sign(body.global_position.x - global_position.x)
		
		print("   Jugador está a la:", "derecha" if player_direction > 0 else "izquierda")
		print("   Cangrejo mirando:", "derecha" if direction == 1 else "izquierda")
		
		# Si el jugador está en la dirección hacia donde camina el cangrejo
		if player_direction == direction:
			# Cambiar dirección (dar la vuelta)
			direction *= -1
			velocity.x = speed * direction
			update_sprite_direction()
			
			print("   🔄 Cangrejo cambió dirección (se aleja del jugador)")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == 'AttackHitbox':
		take_damage()

func _on_idle_timer_timeout() -> void:
	if state_machine.get_current_node() == 'run' and can_move:
		var saved_velocity = velocity.x
		
		state_machine.travel('idle')
		velocity.x = 0
		
		await get_tree().create_timer(0.8).timeout
		
		if can_move and not is_damaged and not is_dead:
			state_machine.travel('run')
			velocity.x = saved_velocity
