extends RigidBody3D

@export var chase_player : bool = true # DEBUG
@export var player : Node
@export var speed : float = 8.0
#@export var speed_threshold : float = 0.25 # % of speed var to determine when zombie should climb
@export var wall_threshold : float = 2.0 # Distance from wall before enemies start climbing
@export var ground_threshold : float = 0.3 # 0.5 good value

var is_climbing : bool = false
var update_offset : int = randi_range(0, 16)
var player_offset : Vector3 = Vector3(randf_range(-15, 15), 0, randf_range(-15, 15))
var force : Vector3 = Vector3.ZERO

func _ready() -> void:
	if randf_range(0, 1) < 0.3:
		$MeshInstance3D.cast_shadow = true
	else:
		$MeshInstance3D.cast_shadow = false
	
	max_contacts_reported = 2
	continuous_cd = true
	print("new script")
	#$MeshInstance3D.position.y -= ground_threshold # until hovering is fixed mesh is pushed down

func _physics_process(delta: float) -> void:
	if (Engine.get_physics_frames() + update_offset) % 16 == 0:
		update_force(delta)
	apply_central_force(force)

func update_force(delta):
	if !chase_player:
		return # DEBUG
	
	var distance = (player.position - position).length()
	var direction : Vector3
	if distance > 1:
		direction = (player.position + player_offset - position).normalized()
	else: 
		direction = (player.position - position).normalized()
	
	
	force.x = direction.x * speed * (clampf(position.y * 0.25, 1.0, 3.0) + clampf(distance / 25, 1.0, 3.0))
	force.z = direction.z * speed * (clampf(position.y * 0.25, 1.0, 3.0)  + clampf(distance / 25, 1.0, 3.0))
	
	#Climbing code
	if position.y < 6 && (Engine.get_physics_frames() + update_offset) % 8 == 0:
		check_wall(direction)
	elif position.y >= 6:
		is_climbing = false
		force.y = -200
	
	if is_climbing:
		force.y = 200
	
	#apply_central_force(force)

func check_wall(direction):
	var ray = get_world_3d().direct_space_state 
	var origin = position
	var destination = position + (Vector3(direction.x, position.y, direction.z) * 5.0)
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = [player]
	var result = ray.intersect_ray(query)
	
	if result:
		var wall_pos = result.position
		var distance = (wall_pos - position).length()
		
		if distance < wall_threshold && is_on_ground():
			is_climbing = true
		else:
			is_climbing = false

func is_on_ground():
	var ray = get_world_3d().direct_space_state 
	var origin = position# - Vector3(0, 0.5 - 0.01, 0) # This corrects on ground recognising self but dulls the horde, removing it makes horde float at ground_threshold
	var destination = origin - Vector3(0, ground_threshold, 0)
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	query.exclude = [player]
	var result = ray.intersect_ray(query)
	
	if result:
		return true
	else:
		return false
		
