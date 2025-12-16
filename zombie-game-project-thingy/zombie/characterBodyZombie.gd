extends CharacterBody3D

@onready var player = get_node("../Player")
@export var speed : float = 8.0
@export var player_threshold : float = 3

var previous_position : Vector3

func _physics_process(delta: float) -> void:
	var player_pos : Vector3 = player.position
	
	var direction : Vector3 = (player_pos + Vector3(randf(), randf(), randf()) - position).normalized()
	
	velocity.x = direction.x * speed + randf_range(-0.5, 0.5)
	#velocity.y = direction.y
	velocity.z = direction.z * speed + randf_range(-0.5, 0.5)
	
	if !is_on_floor():
		velocity.y -= 30 * delta
	
	move_and_slide()
	
	var distance_travelled = self.position - previous_position
	var actual_speed = distance_travelled.length() / delta
	
	var touching_player : bool = false
	var distance_player = Vector3(player_pos.x - position.x, player_pos.y - position.x, player_pos.z - position.z)
	if distance_player.length() < player_threshold:
		touching_player = true
	else: 
		touching_player = false
	
	if speed > 0 && actual_speed < speed * 0.25 && !touching_player:
		velocity.y = 4
	
	previous_position = self.position
