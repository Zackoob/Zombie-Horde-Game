extends Node

@export var straggler_distance : float # Determines how far a zombie is from the horde to be a straggler
@export var group_size : int = 100 # Size of group that will have status updated each frame
@export var sample_size : int = 200 # Size of sample group to find horde position
@export var alerted_distance : float = 70.0
@export var chase_distance : float = 100.0 # Distance aggressive horde can be from player before turning passive
@export var update_timer : int = 1000
@export var aggressive_timer : int = 200
@export var player : Node3D

var zombies : Array[RigidBody3D]
var horde_position : Vector3 # Passive horde position
var aggressive_horde_position : Vector3 
var passive_position : Vector3
var group_index : int = 0
var behaviour : int = 0


func _ready() -> void:
	for zombie in get_children():
		zombies.append(zombie)
	
	set_behaviour(0)
	find_passive_horde_position()

func _process(delta: float) -> void:
	if !player:
		return
	
	check_behaviour()
	
	# Set passive behaviour to zombies
	if behaviour == 0 && update_timer <= 0:
		set_behaviour(0)
		if horde_position != Vector3.ZERO:
			horde_position += Vector3(randf_range(-50, 50), 0.0, randf_range(-50, 50))
			print(horde_position)
		else:
			find_passive_horde_position()
		update_timer = 1000
	else:
		update_timer -= 1
		#print(update_timer)
	
	# Set aggressive behaviour to zombies
	if behaviour == 2 && aggressive_timer <= 0:
		set_behaviour(2)
		aggressive_timer = 200
	else:
		aggressive_timer -= 1

func check_behaviour():
	var player_distance_passive = (player.global_position - horde_position).length()
	var player_distance_aggressive
	if aggressive_horde_position != null:
		player_distance_aggressive = (player.global_position - horde_position).length()
	if player_distance_passive < alerted_distance || player_distance_aggressive < chase_distance:
		behaviour = 2
	else: 
		behaviour = 0

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
	
	horde_position = Vector3.ZERO
	for i in position_array.size():
		horde_position += position_array[i]
	
	horde_position /= position_array.size()
	horde_position = Vector3(horde_position.x, 0.0, horde_position.z)

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
	for i in position_array.size():
		horde_position += position_array[i]
	
	horde_position /= position_array.size()
	horde_position = Vector3(horde_position.x, 0.0, horde_position.z)

func killed_zombie(zombie):
	zombies.erase(zombie)
