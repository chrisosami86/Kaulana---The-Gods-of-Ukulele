extends Area2D

@onready var run_tutorial: CanvasLayer = $"../RunTutorial"


func _ready() -> void:
	if GameState.should_show_tutorial("run"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		GameState.mark_tutorial_shown("run")
		run_tutorial.visible = true
		await get_tree().process_frame
		$"../RunTutorial/MainContainer/MarginContainer/VBoxContainer/Button".grab_focus()
		get_tree().paused = true
		queue_free()
