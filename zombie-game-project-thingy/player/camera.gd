extends Node3D

@export var camera_target : Node3D
@export var pitch_max : float = 25
@export var pitch_min : float = -50
var yaw = float()
var pitch = float()
var yaw_sensitivity : float = .002
var pitch_sensitivity : float = .002

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
	elif Input.is_action_pressed("menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	camera_target.rotation.y = lerpf(camera_target.rotation.y, yaw, delta * 6)
	camera_target.rotation.x = lerpf(camera_target.rotation.x, pitch, delta * 6)
	
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
