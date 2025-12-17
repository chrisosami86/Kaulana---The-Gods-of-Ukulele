extends StaticBody2D

@onready var timer: Timer = $Timer
@onready var saw_audio: AudioStreamPlayer2D = $SawAudio

@export var speed: int
var direction = 1

func _ready() -> void:
	saw_audio.play()


func _physics_process(_delta: float) -> void:
	move_saw()


func move_saw():
	position.y += speed * direction
	



func _on_timer_timeout() -> void:
	direction = direction * -1
