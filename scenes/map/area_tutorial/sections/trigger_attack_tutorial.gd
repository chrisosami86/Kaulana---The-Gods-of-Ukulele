extends Area2D
@onready var attack_tutorial: CanvasLayer = $"../AttackTutorial"
@onready var audio_tutorial: AudioStreamPlayer2D = $"../../AudioTutorial"

func _ready() -> void:
	if GameState.should_show_tutorial("attack"):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	audio_tutorial.play()
	if area.name == "HurtBox":
		attack_tutorial.visible = true
		GameState.mark_tutorial_shown("attack")
		await get_tree().process_frame
		$"../AttackTutorial/MainContainer/MarginContainer/VBoxContainer/Button".grab_focus()
		get_tree().paused = true
		queue_free()
