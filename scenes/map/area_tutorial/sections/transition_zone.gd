extends Area2D
@export var next_section_path: String
@export var player_spawn_position: Vector2



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox": # o "Player"
		get_tree().get_first_node_in_group("main").fade_to_black_and_change_scene(next_section_path, player_spawn_position)
