extends StaticBody2D

@onready var timer: Timer = $Timer

@export var speed: int
var direction = 1


func _physics_process(delta: float) -> void:
	move_saw()


func move_saw():
	position.y += speed * direction
	



func _on_timer_timeout() -> void:
	direction = direction * -1
