extends Area2D

@onready var health_tutorial: CanvasLayer = $"../HealthTutorial"
@onready var audio_tutorial: AudioStreamPlayer2D = $"../../AudioTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("health"):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		audio_tutorial.play()
		health_tutorial.visible = true
		GameState.mark_tutorial_shown("health")
		await get_tree().process_frame
		$"../HealthTutorial/MainContainer/MarginContainer/VBoxContainer/Button".grab_focus()
		get_tree().paused = true
		queue_free()
