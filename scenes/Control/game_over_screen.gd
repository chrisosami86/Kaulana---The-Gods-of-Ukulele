extends Control

@export var next_scene_path: String = "res://scenes/Control/start_screen.tscn"
@export var start_actions: Array = ["ui_accept", "attack"]

var started := false

func _ready() -> void:
	# Aseguramos que esté completamente opaco al iniciar
	$ColorRect.modulate.a = 1.0
	# Iniciamos el fade in con un tween
	_fade_in()


func _input(event: InputEvent) -> void:
	if started:
		return

	if start_actions.size() > 0:
		for a in start_actions:
			if Input.is_action_just_pressed(a):
				_start()
				return
	else:
		if (event is InputEventKey and event.pressed) or \
		   (event is InputEventMouseButton and event.pressed) or \
		   (event is InputEventJoypadButton and event.pressed):
			_start()


func _start() -> void:
	started = true
	_fade_out()


# -----------------
# Funciones de fade
# -----------------
func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, 1.5) # de 1 → 0 en 1.5s

func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 1.5) # de 0 → 1 en 1.5s
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
