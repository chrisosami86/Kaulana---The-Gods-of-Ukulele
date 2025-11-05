extends Area2D

@onready var save_tutorial: CanvasLayer = $"../SaveTutorial"


func _ready() -> void:
	if GameState.should_show_tutorial("save"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		GameState.mark_tutorial_shown("save")
		save_tutorial.visible = true
		get_tree().paused = true
		queue_free()
