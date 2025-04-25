@tool
class_name TargetPuck
extends RigidBody3D

@export var radius: float = 1.0: set = set_radius

func set_radius(new_radius):
	radius = new_radius
	$collision_shape_3d.shape.radius = new_radius
	$csg_cylinder_3d.radius = new_radius
