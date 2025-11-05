extends Area2D

@onready var crouched_attack: CanvasLayer = $"../CrouchedAttack"


func _ready() -> void:
	if GameState.should_show_tutorial("crouched"):
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtBox":
		GameState.mark_tutorial_shown("crouched")
		crouched_attack.visible = true
		get_tree().paused = true
		queue_free()
