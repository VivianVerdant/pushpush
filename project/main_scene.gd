extends Node3D

@onready var puck_pusher_pivot = $puck_pusher_pivot
@onready var puck_pusher = %puck_pusher
@onready var puck_pusher_target = %puck_pusher_target
var puck_pusher_tween: Tween
@onready var camera: OrbitalCamera = $camera_pivot/orbit_camera
@onready var push_button = $GUI/margin_container/push_button
var current_puck: Player_Puck

@onready var sleep_timer_label = %sleep_timer_label

@onready var player_puck_scene = preload("res://player_puck.tscn")
@onready var score_effect = preload("res://score_effects.tscn")

@export var intro_time: float = 2.0
@export var arena_radius: float = 3.0

var active_pucks_in_arena = []
var waiting_for_falling_pucks = false
var waiting_to_spawn_puck = false
var platform_moving = false
var mid_push = false
var sleep_timer = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_new_player_puck()
	camera.move_to_position(Vector3(-.35, TAU/2.0, 0.0), 7, intro_time)
	var tween = get_tree().create_tween()
	tween.tween_property(push_button, "disabled", true, intro_time)
	tween.tween_property(push_button, "disabled", false, 0)
	
	var effect = score_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = Vector3(0.0, 100.0, 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	waiting_for_falling_pucks = false
	for puck:RigidBody3D in active_pucks_in_arena:
		if not puck.sleeping:
			waiting_for_falling_pucks = true
	
	if not waiting_to_spawn_puck:
		sleep_timer = 5
	if waiting_to_spawn_puck and waiting_for_falling_pucks:
		sleep_timer -= delta
	if sleep_timer <= 0.0:
		for puck:RigidBody3D in active_pucks_in_arena:
			puck.sleeping = true
	sleep_timer_label.text = str(sleep_timer)
	
	if waiting_to_spawn_puck and not waiting_for_falling_pucks:
		waiting_to_spawn_puck = false
		mid_push = false
		create_new_player_puck()
	
	if puck_pusher_pivot.rotation.y != camera._rotation.y:
		platform_moving = true
		#print(puck_pusher_pivot.rotation.y, " ", camera._rotation.y)
	else:
		platform_moving = false
	
	if mid_push or platform_moving:
		push_button.disabled = true
	else:
		push_button.disabled = false

func _on_orbit_camera_rotation_updated(camera_rotation: Variant) -> void:
	#print(camera_rotation)
	if [Player_Puck.PUCK_STATES.PREPUSH].has(current_puck.current_state):
		puck_pusher_pivot.rotation.y = lerp_angle(puck_pusher_pivot.rotation.y, camera_rotation.y, 0.03)
		if abs(puck_pusher_pivot.rotation.y - camera_rotation.y) < 0.001:
			puck_pusher_pivot.rotation.y = camera_rotation.y
		
func _on_push_button_pressed() -> void:
	mid_push = true
	current_puck.current_state = Player_Puck.PUCK_STATES.PUSHING
	if puck_pusher_tween:
		puck_pusher_tween.kill()
	puck_pusher_tween = get_tree().create_tween()
	puck_pusher_tween.parallel()
	puck_pusher_tween.tween_property(puck_pusher, "position", puck_pusher_target.position, 3)
	puck_pusher_tween.chain().tween_property(current_puck, "current_state", Player_Puck.PUCK_STATES.PLAYED, 0)
	puck_pusher_tween.chain().tween_property(puck_pusher, "position", Vector3(puck_pusher.position.x, puck_pusher.position.y,  puck_pusher.position.z), 1)
	puck_pusher_tween.chain().tween_property(self, "waiting_to_spawn_puck", true, 0)
	puck_pusher_tween.chain().tween_property(self, "sleep_timer", 5.0, 0)

func create_new_player_puck():
	var max_distance = arena_radius
	print("active pucks: ", active_pucks_in_arena)
	for puck:Node3D in active_pucks_in_arena:
		if puck.position.distance_to(Vector3.ZERO) + puck.radius > max_distance:
			max_distance = puck.position.distance_to(Vector3.ZERO) + puck.radius
	print("max distance: ", max_distance)
	current_puck = player_puck_scene.instantiate()
	add_child(current_puck)
	current_puck.pusher = puck_pusher
	current_puck.radius = randf_range(0.25,1.0)
	current_puck.global_transform = puck_pusher.global_transform
	current_puck.current_state = Player_Puck.PUCK_STATES.PREPUSH
	puck_pusher.position.z = max_distance + (current_puck.radius * 2.0)
	puck_pusher_target.position.z = arena_radius - current_puck.radius

func _on_kill_plane_body_entered(body: Node3D) -> void:
	#print(body)
	var effect = score_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = body.global_position + Vector3(0.0, 1.0, 0.0)
	body.queue_free()

func _on_active_arena_body_entered(body: Node3D) -> void:
	if body.is_in_group("puck"):
		active_pucks_in_arena.push_back(body)
		print("added body to arena: ", body)

func _on_active_arena_body_exited(body: Node3D) -> void:
	if active_pucks_in_arena.has(body):
		active_pucks_in_arena.erase(body)
		print("removed body from arena: ", body)
