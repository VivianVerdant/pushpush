@tool
class_name TargetPuck
extends RigidBody3D

@export var radius: float = 1.0: set = set_radius

@onready var label = $label_3d

enum PUCK_STATES {UNPLAYED, PLAYED, DEAD}
var current_state = PUCK_STATES.PLAYED:
	set = state_changed

func  _process(_delta: float) -> void:
	#debug_label.text = PUCK_STATES.keys()[current_state ] + "\n Freeze: " + str(freeze) + "\n Velocity: " + str(linear_velocity)
	label.text = "Sleeping: " + str(sleeping)

func state_changed(new_state):
	current_state = new_state
	match current_state:
			PUCK_STATES.UNPLAYED:
				visible = false
			PUCK_STATES.PLAYED:
				visible = true
			PUCK_STATES.DEAD:
				visible = false


func set_radius(new_radius):
	radius = new_radius
	$collision_shape_3d.shape.radius = new_radius
	$csg_cylinder_3d.radius = new_radius
