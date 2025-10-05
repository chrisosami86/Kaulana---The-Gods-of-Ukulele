extends CharacterBody2D

@export var move_speed: float
var direction_wall = -1
var health = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Referencias a los nodos que detectan paredes
#y abismos
#Referencia al nodo de animación
@onready var wall_ray: RayCast2D = $WallRay
@onready var ground_ray: RayCast2D = $GroundRay
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $IdleTimer

var is_idle = false
var is_damage = false


func _physics_process(delta: float) -> void:
	move_x()
	wall_detection()
	abyss_detection()
	update_animation()
	move_and_slide()


func move_x():	
	velocity.y += gravity
	velocity.x = direction_wall * move_speed


func flip():
	scale.x *=-1

func die():
	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	queue_free()

func take_damage():
	if is_damage:
		return
	if health > 0:
		var direction_wall_aux = direction_wall
		direction_wall = 0
		is_damage = true
		health -= 1
		animated_sprite_2d.play("damage")
		await animated_sprite_2d.animation_finished
		await get_tree().create_timer(0.2).timeout
		direction_wall = direction_wall_aux
		is_damage = false
	if health <= 0:
		direction_wall = 0;
		die()


func wall_detection():
	if wall_ray.is_colliding():
		direction_wall *= -1
		flip()
	

func abyss_detection():
	if not ground_ray.is_colliding():
		direction_wall *= -1
		flip()

func update_animation():
	if is_damage:
		return
	if health <= 0:
		return  
	
	if is_idle:
		animated_sprite_2d.play("idle")
	elif velocity.x != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")


func _on_idle_timer_timeout() -> void:
	is_idle = true
	velocity.x = 0
	var direction_wall_aux = direction_wall
	direction_wall = 0
	animated_sprite_2d.play("idle")
	await get_tree().create_timer(1.0).timeout
	direction_wall = direction_wall_aux
	is_idle = false


func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage()
