extends Area2D

@onready var health_tutorial: CanvasLayer = $"../HealthTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("health"):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		health_tutorial.visible = true
		GameState.mark_tutorial_shown("health")
		get_tree().paused = true
		queue_free()
