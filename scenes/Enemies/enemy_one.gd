extends CharacterBody2D

@export var speed: float = 50.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = -1
var health = 2
var is_damaged = false
var is_dead = false
var is_idle = false

@onready var wall_ray: RayCast2D = $WallRay
@onready var ground_ray: RayCast2D = $GroundRay
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var idle_timer: Timer = $IdleTimer

func _ready() -> void:
	state_machine.travel('run')
	velocity.x = -speed
	velocity.y = gravity

func _physics_process(_delta: float) -> void:
	move()
	move_and_slide()
	

func move():
	if wall_ray.is_colliding() or !ground_ray.is_colliding():
		velocity.x *= direction
		scale.x *= direction


func take_damage():	
	if state_machine.get_current_node() == 'die':
		return
		
	state_machine.travel('damage')
	health -= 1
	var aux = velocity.x
	velocity.x = 0
	await get_tree().create_timer(0.4).timeout
	velocity.x = aux
		
	if health <= 0:
		velocity.x = 0
		die()
	else:
		state_machine.travel('run')


func die():
	state_machine.travel('die')
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(0.5).timeout
	queue_free()



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == 'AttackHitbox':
		take_damage()


func _on_idle_timer_timeout() -> void:
	if state_machine.get_current_node() == 'run':
		state_machine.travel('idle')
		var aux2 = velocity.x
		velocity.x = 0
		await get_tree().create_timer(0.8).timeout
		state_machine.travel('run')
		velocity.x = aux2
