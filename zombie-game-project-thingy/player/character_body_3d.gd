extends CharacterBody3D

@export var acceleration : float = 40
@export var gravity : float = 30
@export var jump_force : float = 10

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
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		#$Pivot.basis = basis.looking_at(direction)
	
	if is_on_floor():
		velocity.x = direction.x * acceleration
		velocity.z = direction.z * acceleration
	else:
		velocity.x = (direction.x * acceleration) * 0.25
		velocity.z = (direction.z * acceleration) * 0.25
	
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("jump") && is_on_floor():
		velocity.y += jump_force
	
	move_and_slide()
