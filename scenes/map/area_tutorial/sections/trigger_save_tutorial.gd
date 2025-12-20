extends Area2D

@onready var save_tutorial: CanvasLayer = $"../SaveTutorial"
@onready var audio_tutorial: AudioStreamPlayer2D = $"../../AudioTutorial"


func _ready() -> void:
	if GameState.should_show_tutorial("save"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	audio_tutorial.play()
	if area.name == "HurtBox":
		GameState.mark_tutorial_shown("save")
		save_tutorial.visible = true
		await get_tree().process_frame
		$"../SaveTutorial/MainContainer/MarginContainer/VBoxContainer/Button".grab_focus()
		get_tree().paused = true
		queue_free()
