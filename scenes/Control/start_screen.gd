extends Control

@export var next_scene_path: String = "res://scenes/map/main.tscn"
@export var start_actions: Array = ["ui_accept", "attack"]

var started = false

func _ready() -> void:
	# Aseguramos que esté completamente opaco al iniciar
	$ColorRect.modulate.a = 1.0
	# Iniciamos el fade in con un tween
	_fade_in()


func _start() -> void:
	started = true
	_fade_out()


# -----------------
# Funciones de fade
# -----------------
func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.5) # de 1 → 0 en 1.5s

func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.5) # de 0 → 1 en 1.5s
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)


func _on_new_game_button_pressed() -> void:
	_start()


func _on_load_button_pressed() -> void:
	print("Cargando partida")
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()
