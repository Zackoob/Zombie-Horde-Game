extends CharacterBody3D

@onready var player = get_node("../Player")
@export var speed : float = 8.0

func _physics_process(delta: float) -> void:
	var player_pos : Vector3 = player.position
	
	var direction : Vector3 = (player_pos - self.position).normalized()
	
	velocity = direction * speed
	
	move_and_slide()
