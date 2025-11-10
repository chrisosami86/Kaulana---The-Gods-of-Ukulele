extends Area2D


@export var congratulation_scene: PackedScene



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var congratulation  = congratulation_scene.instantiate()
		get_parent().add_child(congratulation)
		get_tree().paused = true
