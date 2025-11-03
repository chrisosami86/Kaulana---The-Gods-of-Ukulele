extends Area2D

@onready var attack_tutorial: CanvasLayer = $"../AttackTutorial"

func _ready() -> void:
	if GameState.save_data["tutorials_shown"]["attack"] == true:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		attack_tutorial.visible = true
		get_tree().paused = true
		queue_free()
