extends Node

var view_delta: Vector2 = Vector2.ZERO

var mouse_sensitivity = .001


func _update(delta) -> void:
	if InputEventMouseMotion:
		pass
		#view_delta.x = -event.screen_velocity.x * mouse_sensitivity
		#view_delta.y = event.screen_velocity.y * mouse_sensitivity
