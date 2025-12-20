extends Area2D

@onready var jump_tutorial: CanvasLayer = $"../JumpTutorial"
@onready var audio_tutorial: AudioStreamPlayer2D = $"../../AudioTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("jump"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	audio_tutorial.play()
	if area.name == "HurtBox":
		audio_tutorial.play()
		GameState.mark_tutorial_shown("jump")
		jump_tutorial.visible = true
		await get_tree().process_frame
		$"../JumpTutorial/MainContainer/MarginContainer/VBoxContainer/Button".grab_focus()
		get_tree().paused = true
		queue_free()
