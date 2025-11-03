extends Area2D

@onready var jump_tutorial: CanvasLayer = $"../JumpTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("jump"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		GameState.mark_tutorial_shown("jump")
		jump_tutorial.visible = true
		get_tree().paused = true
		queue_free()
