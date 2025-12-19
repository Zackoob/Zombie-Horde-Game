extends CharacterBody3D

@export var acceleration : float = 40
@export var gravity : float = 30
@export var jump_force : float = 10

# Camera stuff
@export var camera_target : Node3D
@export var camera_parent : Node3D
var camera_t = float()
var cam_speed = float()

var camera_direction : Vector3

func _physics_process(delta: float) -> void:
	var direction : Vector3 = Vector3.ZERO
	camera_t = camera_target.global_transform.basis.get_euler().y #this might be fine
	
	if Input.is_action_pressed("forward"):
		direction.z -= 1.0
	if Input.is_action_pressed("backward"):
		direction.z += 1.0
	if Input.is_action_pressed("left"):
		direction.x -= 1.0
	if Input.is_action_pressed("right"):
		direction.x += 1.0
	
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		camera_direction = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, camera_t).normalized() #this
		rotation.y = lerp_angle(rotation.y, atan2(-camera_direction.x, -camera_direction.z), delta * acceleration) #this
	
	var input_velocity : Vector3
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	if is_on_floor():
		input_velocity.x = direction.x * acceleration
		input_velocity.z = direction.z * acceleration
	else:
		input_velocity.x = (direction.x * acceleration) * 0.25
		input_velocity.z = (direction.z * acceleration) * 0.25
	
	input_velocity = input_velocity.rotated(Vector3.UP, camera_t).normalized() * acceleration
	velocity = input_velocity
	
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("jump") && is_on_floor():
		velocity.y += jump_force
	
	move_and_slide()
	camera_smooth_follow(delta)

func camera_smooth_follow(delta):
	var cam_offset = Vector3(1.10, 1.5, 0).rotated(Vector3.UP, camera_t)
	cam_speed = 250
	var cam_timer = clamp(delta * cam_speed / 20, 0, 1)
	camera_parent.global_transform.origin = camera_parent.global_transform.origin.lerp(self.global_transform.origin + cam_offset, cam_timer)

func shoot():
	var ray = get_world_3d().direct_space_state
	var origin = camera_parent.global_position
	var destination = origin + -camera_target.global_transform.basis.z * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = [self]
	var result = ray.intersect_ray(query)
	var collider = result.get("collider")
	
	DebugDraw3D.draw_line(origin, destination, Color.RED)
	
	if collider:
		print("Hit", get_node(collider.get_path()))
		get_node(collider.get_path()).queue_free()
	else:
		print("Missed", collider)
	
