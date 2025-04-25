extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$gpu_particles_3d.emitting = true

func _on_gpu_particles_3d_finished() -> void:
	self.queue_free()
