extends CharacterBody3D

@onready var player = get_node("../Player")
@export var speed : float = 8.0
@export var player_threshold : float = 2

var previous_position : Vector3

func _physics_process(delta: float) -> void:
	var player_pos : Vector3 = player.position
	
	var direction : Vector3 = (player_pos - self.position)
	var direction_norm : Vector3 = direction.normalized()
	
	velocity.x = direction_norm.x * speed
	velocity.z = direction_norm.z * speed
	
	if !is_on_floor():
		velocity.y -= 30 * delta
	
	move_and_slide()
	
	var distance_travelled = self.position - previous_position
	var actual_speed = distance_travelled.length() / delta
	
	var touching_player : bool = false
	if direction.length() < player_threshold:
		touching_player = true
	else: 
		touching_player = false
	
	print(touching_player)
	if speed > 0 && actual_speed < speed * 0.5 && !touching_player:
		print("stuck")
		velocity.y = 4
	
	previous_position = self.position
