extends CanvasLayer




func _ready() -> void:
	$PanelContainer/VBoxContainer/Button.grab_focus()

func _on_button_pressed() -> void:
	get_tree().quit()
