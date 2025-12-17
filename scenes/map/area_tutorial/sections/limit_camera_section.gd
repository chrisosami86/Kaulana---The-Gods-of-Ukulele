extends Node2D

# Rect2 local (posición y tamaño) relativos al root de la sesión.
# Ajusta estos valores en el inspector por cada sesión.
@export var camera_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1024, 720))
const BOSS_DIALOGUE = preload("uid://ben7chjsevk8h")
var audio_main: AudioStreamPlayer2D
var audio_boss: AudioStreamPlayer2D


func _ready() -> void:
	audio_main = get_parent().get_parent().find_child("MainAudio")
	audio_boss = get_parent().get_parent().find_child("BossAudio")
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	
# Devuelve los bounds en coordenadas globales (mundo)
func get_camera_bounds_global() -> Rect2:
	var top_left_global = global_position + camera_bounds.position
	return Rect2(top_left_global, camera_bounds.size)
	
func _on_camera_trigger_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		
		print("📸 Player detectado, actualizando límites de cámara...")
		var main = get_tree().get_first_node_in_group("main")
		if main:
			var cam = get_tree().get_first_node_in_group("player").get_node("Camera2D")
			main.set_camera_limits_from_rect(cam, get_camera_bounds_global())


func _on_trigger_dialogue_body_entered(body: Node2D) -> void:
	if(body.name =="Player"):
		var tween = get_tree().create_tween()
		var main = get_tree().get_first_node_in_group("main")
		if main:
			var cam: Camera2D = get_tree().get_first_node_in_group("player").get_node("Camera2D")
			tween.tween_property(cam, "zoom", Vector2(0.7, 0.7), 0.5)
			tween.tween_property(cam, "limit_left", 800, 0.5)
		DialogueManager.show_dialogue_balloon(BOSS_DIALOGUE,"start")
		audio_main.stream_paused = true
		audio_boss.play()
		$TriggerDialogue.set_collision_mask_value(2,false)
		$WallLimited.set_collision_layer_value(1, true)
		var life_bar = get_tree().get_first_node_in_group("main").get_node("CurrentLevel").get_node("Section5").get_node("Enemies").get_node("EnemyThree").get_node("CanvasLayer")
		life_bar.visible = true
		


func _on_dialogue_started(_dialogue):
	GameState.is_dialogue_active = true

func _on_dialogue_ended(_dialogue):
	GameState.is_dialogue_active = false
