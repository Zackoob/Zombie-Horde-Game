extends Node3D

@export var straggler_distance : float # Determines how far a zombie is from the horde to be a straggler
@export var group_size : int = 100 # Size of group that will have status updated each frame
@export var sample_size : int = 200 # Size of sample group to find horde position
@export var alerted_distance : float = 70.0
@export var chase_distance : float = 100.0 # Distance aggressive horde can be from player before turning passive
@export var map_size : float = 200.0 # Distance from 0,0,0 map spans in each direction
@export var min_horde_size : int = 25 # Minimum horde size on game start, hordes can still be killed off and smaller than the min
@export var max_horde_size : int = 400 # Maximum horde size on game start, hordes can still merge and grow larger than the max
@export var update_timer : int = 30
@export var aggressive_timer : int = 200
@export var player : Node3D
@export var horde_count : int = 5

var zombies : Array[RigidBody3D] = []
var hordes : Array[horde] = []
var update_ticker : int = 0 
var check_ticker : int = 0 
var aggressive_horde_position : Vector3 
var passive_position : Vector3
var group_index : int = 0
#var behaviour : int = 0

class horde :
	var id : int
	var hposition : Vector3
	var behaviour : int
	var horde_zombies : Array[RigidBody3D] = []
	var radius : float
	var timer : int

func _ready() -> void:
	for zombie in get_children():
		zombies.append(zombie)
	
	await get_tree().physics_frame
	for i in range(horde_count):
		var new_horde = horde.new()
		new_horde.id = i
		set_horde_position(new_horde)
		new_horde.behaviour = 0
		assign_zombies(new_horde)
		new_horde.radius = clampf(new_horde.horde_zombies.size() / 15, 10, 50)
		hordes.append(new_horde)
		spawn_zombies(new_horde)
		new_horde.timer = i * 100

# Function to set horde position on runtime
func set_horde_position(new_horde):
	# Loop until generated position is valid
	while true:
		var horde_position = Vector3(randf_range(-map_size, map_size), 0.0, randf_range(-map_size, map_size)) # Generate position
		
		# Check if position is not in building
		if check_position_valid(horde_position):
			new_horde.hposition = horde_position
			break

# Function that assigns zombies to horde on runtime
func assign_zombies(new_horde):
	var horde_size : int = randi_range(min_horde_size, max_horde_size)
	if horde_size > zombies.size() || new_horde.id == horde_count - 1:
		horde_size = zombies.size()
	
	for i in range(horde_size):
		var zombie = zombies[0]
		zombie.horde = new_horde.id
		new_horde.horde_zombies.append(zombie)
		zombies.erase(zombie)

# Function to spawn zombies at horde position
func spawn_zombies(new_horde):
	for zombie in range(new_horde.horde_zombies.size()):
		var zombie_position
		while true:
			zombie_position = Vector3(new_horde.hposition.x + randf_range(-new_horde.radius, new_horde.radius), randf_range(new_horde.hposition.y, 6), new_horde.hposition.z + randf_range(-new_horde.radius, new_horde.radius))
			
			if check_position_valid(zombie_position):
				new_horde.horde_zombies[zombie].global_position = zombie_position
				break

func _physics_process(delta: float) -> void:
	if !player:
		return 
	
	# Check if horde should be aggressive or passive
	if check_ticker >= update_timer * 4:
		check_player_distance()
	else:
		check_ticker += 1
	
	# Update position of passive hordes
	if update_ticker >= update_timer * 2:
		update_horde_position()
		
	else:
		update_ticker += 1
	

func update_horde_position():
	update_ticker = 0
	for i in range(hordes.size()):
		if hordes[i].behaviour == 0: 
			var generate_cap : int = 25
			var horde_position : Vector3
			for j in range(generate_cap):
				horde_position = hordes[i].hposition + Vector3(randf_range(-10, 10), 0.0, randf_range(-10, 10))
				
				if check_position_valid(horde_position):
					hordes[i].hposition = horde_position
					break
			if hordes[i].hposition == Vector3.ZERO:
				hordes[i].hposition = horde_position

func check_player_distance():
	check_ticker = 0
	for i in range(hordes.size()):
		check_horde_position(hordes[i])
		var distance = (player.position - hordes[i].hposition).length()
		if distance < alerted_distance + (hordes[i].radius / 2):
			hordes[i].behaviour = 2
			print("aggressive")
		elif hordes[i].behaviour == 2 && distance > alerted_distance:
			hordes[i].behaviour = 0

func check_horde_position(current_horde : horde):
	var sample_size : int = int(current_horde.horde_zombies.size() / 2)
	if current_horde.horde_zombies.size() == 0:
		return
	
	var horde_average_position : Vector3 = Vector3.ZERO
	for i in range(sample_size):
		horde_average_position += current_horde.horde_zombies[i].position
	
	horde_average_position /= sample_size
	current_horde.hposition = horde_average_position

# Function to check if the position is valid (if point is on ground not in building)
func check_position_valid(input_position : Vector3):
	var ray = get_world_3d().direct_space_state
	var origin : Vector3 = Vector3(input_position.x, 200.0, input_position.z)
	var destination : Vector3 = Vector3(origin.x, -10.0, origin.z)
	var query = PhysicsRayQueryParameters3D.create(origin, destination)
	var result = ray.intersect_ray(query)
	
	if result:
		var collider = result.get("collider")
		if collider.is_in_group("ground"):
			return true
		else:
			return false
	else:
		return false



#OLD CODE BELOW



#func check_behaviour():
	#var player_distance_passive = (player.global_position - horde_position).length()
	#var player_distance_aggressive
	#if aggressive_horde_position != null:
		#player_distance_aggressive = (player.global_position - horde_position).length()
	#if player_distance_passive < alerted_distance || player_distance_aggressive < chase_distance:
		#behaviour = 2
	#else: 
		#behaviour = 0

func set_behaviour(new_behaviour : int):
	if !zombies:
		return
	
	for i in range(group_size):
		var zombie = zombies[group_index]
		zombie.behaviour = new_behaviour
		
		group_index += 1
		if group_index >= zombies.size():
			group_index = 0
			print(group_index)

# This function should only be ran once as a baseline for passive horde position, when horde is aggressive clear the horde position and when back to passive check if it is null
func find_passive_horde_position():
	if !zombies:
		return
	
	var zombie_size = zombies.size()
	if zombie_size == 0:
		return
	var position_array : Array[Vector3]
	
	for i in range(sample_size):
		var index = randi() % zombie_size
		var zombie = zombies[index]
		position_array.append(zombie.position)
	
	#horde_position = Vector3.ZERO
	#for i in position_array.size():
		#horde_position += position_array[i]
	
	#horde_position /= position_array.size()
	#horde_position = Vector3(horde_position.x, 0.0, horde_position.z)

func find_aggressive_horde_position():
	if !zombies:
		return
	
	var zombie_size = zombies.size()
	if zombie_size == 0:
		return
	var position_array : Array[Vector3]
	
	for i in range(sample_size):
		var index = randi() % zombie_size
		var zombie = zombies[index]
		if zombie.behaviour == 2:
			position_array.append(zombie.position)
	
	aggressive_horde_position = Vector3.ZERO
	#for i in position_array.size():
		#horde_position += position_array[i]
	
	#horde_position /= position_array.size()
	#horde_position = Vector3(horde_position.x, 0.0, horde_position.z)

func killed_zombie(zombie):
	zombies.erase(zombie)
