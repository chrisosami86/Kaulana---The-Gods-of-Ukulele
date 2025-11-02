extends Area2D

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
var is_in_save_point = false
var is_saving = false


func _ready() -> void:
	state_machine.travel("save_idle")

func _physics_process(delta: float) -> void:
	saveGame()




func saveGame():
	if not is_in_save_point and Input.is_action_just_pressed("move_up") and is_saving:
		return
	
	if is_in_save_point and Input.is_action_just_pressed("move_up") and not is_saving:
		is_saving = true
		state_machine.travel("save_ok")
		var player = get_tree().get_first_node_in_group("player")
		var scene = get_tree().get_first_node_in_group("sections")
		GameState.set_checkpoint(scene.get_path(),player.position)
		print(GameState.save_data["scene_path"])
		print(GameState.save_data["player_position"])
		await get_tree().create_timer(2.64).timeout
		state_machine.travel("save_idle")
		is_saving = false


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = true



func _on_area_exited(area: Area2D) -> void:
	if area.name == "HurtBox":
		is_in_save_point = false
