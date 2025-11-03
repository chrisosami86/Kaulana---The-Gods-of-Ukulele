extends Area2D

@onready var attack_tutorial: CanvasLayer = $"../AttackTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("attack"):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		attack_tutorial.visible = true
		GameState.mark_tutorial_shown("attack")
		get_tree().paused = true
		queue_free()
