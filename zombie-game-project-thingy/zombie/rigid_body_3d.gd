extends RigidBody3D

@export var player : Node
@export var speed : float = 8.0

func _physics_process(delta: float) -> void:
	var direction : Vector3 = (player.position - self.position).normalized()
	
	var force : Vector3 = Vector3.ZERO
	force.x = direction.x * speed
	force.z = direction.z * speed
	
	apply_central_impulse(force)
