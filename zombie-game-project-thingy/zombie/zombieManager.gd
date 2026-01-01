extends Node

@export var straggler_distance : float # Determines how far a zombie is from the horde to be a straggler
@export var group_size : int = 100 # Size of group that will have status updated each frame
@export var sample_size : int = 150 # Size of sample group to find horde position
@export var alerted_distance : float = 70.0
@export var update_timer : int = 500
@export var player : Node3D

var zombies : Array[RigidBody3D]
var horde_position : Vector3
var passive_position : Vector3
var group_index : int = 0
var behaviour : int = 0


func _ready() -> void:
	for zombie in get_children():
		zombies.append(zombie)
	
	set_behaviour(0)
	find_horde_position()

func _process(delta: float) -> void:
	if !player:
		return
	
	var player_distance = (player.global_position - horde_position).length()
	if player_distance < alerted_distance && behaviour != 2:
		set_behaviour(2)
		behaviour = 2
		print("aggressive")
	elif player_distance > alerted_distance && behaviour != 0:
		set_behaviour(0)
		behaviour = 0
		print("passive")
	
	if behaviour == 0 && update_timer == 0:
		if horde_position != Vector3.ZERO:
			horde_position += Vector3(randf_range(-50, 50), 0.0, randf_range(-50, 50))
			print(horde_position)
		else:
			find_horde_position()
		update_timer = 1000
	else:
		update_timer -= 1
		#print(update_timer)

func set_behaviour(new_behaviour : int):
	if !zombies:
		return
	
	for i in range(group_size):
		var zombie = zombies[group_index]
		zombie.behaviour = new_behaviour
		
		group_index += 1
		if group_index >= zombies.size():
			group_index = 0

# This function should only be ran once as a baseline for passive horde position, when horde is aggressive clear the horde position and when back to passive check if it is null
func find_horde_position():
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

func killed_zombie(zombie):
	zombies.erase(zombie)
