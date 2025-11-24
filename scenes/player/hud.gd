class_name HudPlayer

extends CanvasLayer

@onready var hearts = $HBoxContainer.get_children()

func update_hearts(current_health: int, max_health: int):
	for i in range(max_health):
		if i < current_health:
			hearts[i].texture = preload("res://assets/sprites/player/heart_full.png")
		else:
			hearts[i].texture = preload("res://assets/sprites/player/heart_empty.png")
