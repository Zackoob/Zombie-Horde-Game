extends Node3D

@onready var interaction_ray : RayCast3D = $CameraTarget/SpringArm3D/Camera3D/RayCast3D

@export var player_hud : Node
@export var camera_target : Node3D
@export var pitch_max : float = 25
@export var pitch_min : float = -50
var yaw = float()
var pitch = float()
var yaw_sensitivity : float = .002
var pitch_sensitivity : float = .002
var current_interactable = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
	elif Input.is_action_pressed("menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	camera_target.rotation.y = lerpf(camera_target.rotation.y, yaw, delta * 6)
	camera_target.rotation.x = lerpf(camera_target.rotation.x, pitch, delta * 6)
	
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	
	# Interactable
	check_interactable()
	if Input.is_action_just_pressed("interact") && current_interactable:
		current_interactable.interacted(player_hud)

func check_interactable():
	current_interactable = null
	if interaction_ray.is_colliding():
		var item = interaction_ray.get_collider()
		current_interactable = item
		show_prompt()
	else:
		hide_prompt()

func show_prompt():
	if current_interactable:
		player_hud.show_prompt(current_interactable.prompt)

func hide_prompt():
	player_hud.hide_prompt()
