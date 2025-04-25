class_name Player_Puck
extends RigidBody3D

var pusher
@export var radius: float
@export var current_puck: bool = false
@onready var label = $label_3d

enum PUCK_STATES {UNPLAYED, PREPUSH, PUSHING, PLAYED, DEAD}
var current_state = PUCK_STATES.UNPLAYED: set = state_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	freeze = false
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	label.text = PUCK_STATES.keys()[current_state]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	match current_state:
		PUCK_STATES.PREPUSH:
			global_position = pusher.global_position
			global_rotation = pusher.global_rotation
		PUCK_STATES.PUSHING:
			global_position = pusher.global_position
		_:
			pass
	
	label.text = PUCK_STATES.keys()[current_state ] + "\n Freeze: " + str(freeze) + "\n Velocity: " + str(linear_velocity)

func state_changed(new_state):
	current_state = new_state
	match current_state:
		PUCK_STATES.UNPLAYED:
			visible = false
			freeze = true
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		PUCK_STATES.PREPUSH:
			visible = true
			freeze = true
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		PUCK_STATES.PUSHING:
			visible = true
			freeze = true
			freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		PUCK_STATES.PLAYED:
			visible = true
			freeze = false
		PUCK_STATES.DEAD:
			visible = false
			freeze = true
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
