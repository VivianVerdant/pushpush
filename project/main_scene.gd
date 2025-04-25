extends Node3D

@onready var puck_pusher_pivot = $puck_pusher_pivot
@onready var puck_pusher = $puck_pusher_pivot/puck_pusher
var puck_pusher_tween: Tween
@onready var camera: OrbitalCamera = $camera_pivot/orbit_camera
@onready var push_button = $GUI/margin_container/push_button
var current_puck: Player_Puck

@onready var player_puck_scene = preload("res://player_puck.tscn")
@onready var score_effect = preload("res://score_effects.tscn")

@export var intro_time: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_new_player_puck()
	camera.move_to_position(Vector3(-.25, TAU/2.0, 0.0), 6, intro_time)
	var tween = get_tree().create_tween()
	tween.tween_property(push_button, "disabled", true, intro_time)
	tween.tween_property(push_button, "disabled", false, 0)
	
	var effect = score_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = Vector3(0.0, 100.0, 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_orbit_camera_rotation_updated(camera_rotation: Variant) -> void:
	puck_pusher_pivot.rotation = Vector3(0.0, camera_rotation.y, 0.0)

func _on_push_button_pressed() -> void:
	push_button.disabled = true
	camera.input_enabled = false
	current_puck.current_state = Player_Puck.PUCK_STATES.PUSHING
	if puck_pusher_tween:
		puck_pusher_tween.kill()
	puck_pusher_tween = get_tree().create_tween()
	var new_z = puck_pusher.position.z - current_puck.radius*2
	puck_pusher_tween.parallel()
	puck_pusher_tween.tween_property(puck_pusher, "position", Vector3(puck_pusher.position.x, puck_pusher.position.y,  new_z), 3)
	puck_pusher_tween.chain().tween_property(current_puck, "current_state", Player_Puck.PUCK_STATES.PLAYED, 0)
	puck_pusher_tween.chain().tween_property(puck_pusher, "position", Vector3(puck_pusher.position.x, puck_pusher.position.y,  puck_pusher.position.z), 1)
	puck_pusher_tween.chain().tween_property(push_button, "disabled", false, 0)
	puck_pusher_tween.chain().tween_property(camera, "input_enabled", true, 0)
	puck_pusher_tween.chain().tween_callback(create_new_player_puck)
	
func create_new_player_puck():
	current_puck = player_puck_scene.instantiate()
	current_puck.pusher = puck_pusher
	add_child(current_puck)
	current_puck.global_transform = puck_pusher.global_transform
	current_puck.current_state = Player_Puck.PUCK_STATES.PREPUSH


func _on_kill_plane_body_entered(body: Node3D) -> void:
	print(body)
	var effect = score_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = body.global_position + Vector3(0.0, 1.0, 0.0)
	body.queue_free()
