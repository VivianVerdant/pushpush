class_name OrbitalCamera
extends Camera3D

# External var
@export var SCROLL_SPEED: float = 10 # Speed when use scroll mouse
@export var ZOOM_SPEED: float = 5 # Speed use when is_zoom_in or is_zoom_out is true
@export var DEFAULT_DISTANCE: float = 20 # Default distance of the Node
@export var ROTATE_SPEED: float = 10
@export var ANCHOR_NODE_PATH: NodePath
@export var MOUSE_ZOOM_SPEED: float = 10
@export var TOUCH_INVERT_ZOOM: bool = false

# Input controls
@export var input_enabled: bool = true
var auto_movement_tween: Tween
var _is_auto_moving: bool = false
signal auto_movement_completed

# Event var
var _move_speed: Vector2
var _scroll_speed: float
var _touches: Dictionary
var _old_touche_dist: float
# Use to add posibility to updated zoom with external script
var is_zoom_in: bool
var is_zoom_out: bool

# Transform var
var _rotation: Vector3
var _distance: float
var _anchor_node: Node3D

signal camera_rotation_updated(rotation)

func _ready():
	_distance = DEFAULT_DISTANCE
	_anchor_node = self.get_node(ANCHOR_NODE_PATH)
	_rotation = _anchor_node.transform.basis.get_rotation_quaternion().get_euler()
	_rotation.x = -PI/2
	_distance = 10.0

func _process(delta: float):
	if is_zoom_in:
		_scroll_speed = -1 * ZOOM_SPEED
	if is_zoom_out:
		_scroll_speed = 1 * ZOOM_SPEED
	_process_transformation(delta)
	
	$label_3d.text = "Is automoving: " + str(_is_auto_moving) + "\n Tween: " + str(auto_movement_tween.get_total_elapsed_time())

func _process_transformation(delta: float):
	
	# Update rotation
	_rotation.x += -_move_speed.y * delta * ROTATE_SPEED
	_rotation.y += -_move_speed.x * delta * ROTATE_SPEED
	_rotation.x = clampf(_rotation.x, -PI, -0.18)
	if _rotation.x < -PI/2:
		_rotation.x = -PI/2
	if _rotation.x > PI/2:
		_rotation.x = PI/2
	_move_speed = Vector2()
	
	# Update distance
	_distance += _scroll_speed * delta
	_distance = clamp(_distance, 1.5, 10.0)
	_scroll_speed = 0
	
	self.set_identity()
	self.translate_object_local(Vector3(0,0,_distance))
	_anchor_node.set_identity()
	_anchor_node.transform.basis = Basis(Quaternion.from_euler(_rotation))
	
	camera_rotation_updated.emit(_rotation)

func _input(event):
	if input_enabled and not _is_auto_moving:
		if event is InputEventScreenDrag:
			_process_touch_rotation_event(event)
		elif event is InputEventMouseMotion:
			_process_mouse_rotation_event(event)
		elif event is InputEventMouseButton:
			_process_mouse_scroll_event(event)
		elif event is InputEventScreenTouch:
			_process_touch_zoom_event(event)

func _process_mouse_rotation_event(e: InputEventMouseMotion):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_move_speed = e.relative

func _process_mouse_scroll_event(e: InputEventMouseButton):
	if e.button_index == MOUSE_BUTTON_WHEEL_UP:
		_scroll_speed = -1 * SCROLL_SPEED
	elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_scroll_speed = 1 * SCROLL_SPEED

func _process_touch_rotation_event(e: InputEventScreenDrag):
	if _touches.has(e.index):
		_touches[e.index] = e.position
	if _touches.size() == 2:
		var _keys = _touches.keys()
		var _pos_finger_1 = _touches[_keys[0]] as Vector2
		var _pos_finger_2 = _touches[_keys[1]] as Vector2
		var _dist = _pos_finger_1.distance_to(_pos_finger_2)
		if _old_touche_dist != -1:
			_scroll_speed = (_dist - _old_touche_dist) * MOUSE_ZOOM_SPEED
		if TOUCH_INVERT_ZOOM:
			_scroll_speed = -1 * _scroll_speed
		_old_touche_dist = _dist
	elif _touches.size() < 2:
		_old_touche_dist = -1
		_move_speed = e.relative
	
func _process_touch_zoom_event(e: InputEventScreenTouch):
	if e.pressed:
		if not _touches.has(e.index):
			_touches[e.index] = e.position
	else:
		if _touches.has(e.index):	
			# warning-ignore:return_value_discarded
			_touches.erase(e.index)
	
func move_to_position(rotation: Vector3, distance: float = _distance, time: float = 1.0):
	_is_auto_moving = true
	if auto_movement_tween:
		auto_movement_tween.kill() # Abort the previous animation.
	auto_movement_tween = get_tree().create_tween()
	auto_movement_tween.set_trans(Tween.TRANS_SINE)
	auto_movement_tween.set_parallel()
	auto_movement_tween.tween_property(self, "_rotation", rotation, time)
	auto_movement_tween.tween_property(self, "_distance", distance, time)
	#auto_movement_tween.tween_property(self, "_is_auto_moving", false, time)
	auto_movement_tween.chain().tween_callback(_auto_movement_completed)
	
func _auto_movement_completed():
	if auto_movement_tween:
		auto_movement_tween.kill()
	_is_auto_moving = false
	auto_movement_completed.emit()
	
