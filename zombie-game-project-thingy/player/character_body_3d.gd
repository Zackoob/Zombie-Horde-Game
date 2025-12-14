extends CharacterBody3D

@export var speed : int = 10;
@export var fall_acceleration : int = 50

var target_velocity : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction : Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		direction.z -= 1.0
	
	if Input.is_action_pressed("backward"):
		direction.z += 1.0
	
	if Input.is_action_pressed("left"):
		direction.x -= 1.0
	
	if Input.is_action_pressed("right"):
		direction.x += 1.0
	
	#print(direction)
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		#$Pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if !is_on_floor():
		target_velocity.y = direction.y * fall_acceleration
	
	velocity = target_velocity
	move_and_slide()
