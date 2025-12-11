extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var detection_area: Area2D = $DetectionArea
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_attack: AudioStreamPlayer2D = $Audios/AudioAttack
@onready var audio_fly: AudioStreamPlayer2D = $Audios/AudioFly
@onready var audio_damage: AudioStreamPlayer2D = $Audios/AudioDamage
@onready var sfx_damage: AudioStreamPlayer2D = $Audios/SFXDamage
@onready var audio_die: AudioStreamPlayer2D = $Audios/AudioDie



var player: Node2D = null
var speed := 80.0
var hp := 2
var is_damaged := false
var can_move: bool = true

func _ready() -> void:
	state_machine.travel("idle")
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	if state_machine.get_current_node() == "fly" and player:
		fly_towards_player(delta)
		

func fly_towards_player(_delta: float) -> void:
	# No perseguir si no puede moverse
	
	if not can_move or is_damaged or state_machine.get_current_node() == "die":
		velocity = Vector2.ZERO
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if abs(velocity.x) > 0.1:
		$Sprite2D.flip_h = velocity.x > 0


func take_damage() -> void:
	if is_damaged or state_machine.get_current_node() == "die":
		return

	is_damaged = true
	hp -= 1
	state_machine.travel("damage")
	audio_damage.play()
	sfx_damage.play()

	if hp <= 0:
		die()
	else:
		await get_tree().create_timer(0.4).timeout
		is_damaged = false
		state_machine.travel("fly")

func die() -> void:
	audio_die.play()
	state_machine.travel("die")
	velocity = Vector2.ZERO
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(0.7).timeout
	queue_free()

# 👉 Este método se llamará desde la señal del editor (DetectionArea → body_entered)
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_current_node() == "idle":
		player = body
		state_machine.travel("fly")

# 👉 Este se conectará desde el Hurtbox (area_entered)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackHitbox":
		take_damage()

# 🆕 Conectar esta función a body_entered del CharacterBody2D
func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_move:
		can_move = false
		velocity = Vector2.ZERO
		
		await get_tree().create_timer(0.3).timeout
		can_move = true
