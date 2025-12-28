extends CharacterBody3D

@export var walk_acceleration : float = 40
@export var sprint_acceleration : float = 40
@export var gravity : float = 4
@export var jump_force : float = 30

# Camera stuff
@export var camera_target : Node3D
@export var camera_parent : Node3D
var camera_t = float()
var cam_speed = float()
var camera_direction : Vector3

var mag_size : int = 30
var bullets : int = mag_size
var total_bullets : int = 60

func _ready() -> void:
	$PlayerHud.update_bullet_counter(bullets, total_bullets)

func _physics_process(delta: float) -> void:
	var direction : Vector3 = Vector3.ZERO
	camera_t = camera_target.global_transform.basis.get_euler().y 
	
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
		rotation.y = lerp_angle(rotation.y, atan2(-camera_direction.x, -camera_direction.z), delta * walk_acceleration) #this
	
	var input_velocity : Vector3
	
	if is_on_floor():
		input_velocity.x = direction.x * walk_acceleration
		input_velocity.z = direction.z * walk_acceleration
	else:
		input_velocity.x = (direction.x * walk_acceleration) * 0.25
		input_velocity.z = (direction.z * walk_acceleration) * 0.25
	
	
	if Input.is_action_pressed("sprint"):
		input_velocity = input_velocity.rotated(Vector3.UP, camera_t).normalized() * sprint_acceleration
	else:
		input_velocity = input_velocity.rotated(Vector3.UP, camera_t).normalized() * walk_acceleration
	velocity.x = input_velocity.x
	velocity.z = input_velocity.z
	
	if !is_on_floor():
		velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
	camera_smooth_follow(delta)
	
	# Shooting
	if Input.is_action_just_pressed("shoot") && bullets > 0:
		shoot()
		bullets -= 1
		$PlayerHud.update_bullet_counter(bullets, total_bullets)
	
	if Input.is_action_just_pressed("reload"):
		if total_bullets < mag_size:
			var new_total_bullets = total_bullets - (mag_size - bullets)
			if new_total_bullets < 0:
				bullets += total_bullets
				total_bullets = 0
				$PlayerHud.update_bullet_counter(bullets, total_bullets)
			else: 
				total_bullets -= mag_size - bullets
				bullets = mag_size
				$PlayerHud.update_bullet_counter(bullets, total_bullets)
		elif bullets == mag_size:
			print("Magazine is full")
		else:
			total_bullets -= mag_size - bullets
			bullets = mag_size
		$PlayerHud.update_bullet_counter(bullets, total_bullets)

func camera_smooth_follow(delta):
	var cam_offset = Vector3(1.10, 1.5, 0).rotated(Vector3.UP, camera_t)
	cam_speed = 250
	var cam_timer = clamp(delta * cam_speed / 20, 0, 1)
	camera_parent.global_transform.origin = camera_parent.global_transform.origin.lerp(self.global_transform.origin + cam_offset, cam_timer)

func shoot():
	var ray = get_world_3d().direct_space_state
	var origin = camera_target.global_position
	var destination = origin + -camera_target.global_transform.basis.z * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = [self]
	var result = ray.intersect_ray(query)
	var collider = result.get("collider")
	
	DebugDraw3D.draw_line(origin, destination, Color.RED)
	
	if collider && collider.is_in_group("Zombies"):
		get_node(collider.get_path()).queue_free()
