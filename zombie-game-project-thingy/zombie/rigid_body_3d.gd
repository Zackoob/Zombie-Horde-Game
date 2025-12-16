extends RigidBody3D

@export var player : Node
@export var speed : float = 8.0
#@export var speed_threshold : float = 0.25 # % of speed var to determine when zombie should climb
@export var wall_threshold : float = 0.8 # Distance from wall before enemies start climbing
@export var ground_threshold : float = 0.5

var previous_position : Vector3
var is_climbing : bool = false

func _physics_process(delta: float) -> void:
	var distance = (player.position - position).length()
	var direction : Vector3
	if distance > 1:
		direction = (player.position + Vector3(randf_range(-20, 20), 0, randf_range(-20, 20)) - position).normalized()
	else: 
		direction = (player.position - position).normalized()
	
	var force : Vector3 = Vector3.ZERO
	force.x = direction.x * speed
	force.z = direction.z * speed
	
	apply_central_impulse(force)
	
	#Climbing code
	if position.y < 6:
		check_wall()
	else:
		is_climbing = false
	if is_climbing:
		apply_central_impulse(Vector3(0, 4, 0))

func check_wall():
	var ray = get_world_3d().direct_space_state 
	var origin = position
	var destination = player.position
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = [player]
	var result = ray.intersect_ray(query)
	
	if result:
		var wall_pos = result.position
		var distance = (wall_pos - position).length()
		var on_ground : float = randf_range(0, 1)
		
		if distance < wall_threshold:
			is_climbing = true
		else:
			is_climbing = false
