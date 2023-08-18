extends Area2D

class_name DeathZone

signal life_lost

func _on_body_entered(body):
	life_lost.emit()
