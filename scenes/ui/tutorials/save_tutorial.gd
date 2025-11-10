extends CanvasLayer

func _ready() -> void:
	$MainContainer/MarginContainer/VBoxContainer/Button.grab_focus()

func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false
