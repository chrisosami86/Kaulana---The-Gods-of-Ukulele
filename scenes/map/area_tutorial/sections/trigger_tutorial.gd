extends Area2D

@onready var jump_tutorial: CanvasLayer = $"../JumpTutorial"

func _ready() -> void:
	if GameState.save_data["tutorials_shown"]["jump"] == true:
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		GameState.save_data["tutorials_shown"]["jump"] = true
		jump_tutorial.visible = true
		get_tree().paused = true
		queue_free()
