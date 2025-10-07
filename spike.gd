extends Area2D


# Se dispara cuando algo entra en el área de colisión
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
