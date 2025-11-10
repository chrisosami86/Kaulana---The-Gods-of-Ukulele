extends CanvasLayer

@onready var button: Button = $MainContainer/MarginContainer/VBoxContainer/Button

func _ready() -> void:
	button.grab_focus()

func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false
