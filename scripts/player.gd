extends RigidBody3D

# Hover
@onready var hover_ray: RayCast3D = %HoverRay
var hover_height: float = 1.5
var hover_force: float = 100.0
var hover_damping: float = 10.0

# Floor
@onready var floor_ray: RayCast3D = %FloorRay

# Move
var move_speed: float = 20.0

# Jump
var jump_impulse: float = 20.0

func _physics_process(_delta: float) -> void:
	_move()
	_jump()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_hover(state)

func _hover(state: PhysicsDirectBodyState3D) -> void:
	if not _is_on_floor(): return
	if not hover_ray.is_colliding(): return
	
	var hit: Vector3 = hover_ray.get_collision_point()
	var height: float = state.transform.origin.y - hit.y
	var displacement: float = height - hover_height
	var spring_force: float = -hover_force * displacement
	var damping_force: float = -hover_damping * state.linear_velocity.y
	var total_upward: float = spring_force + damping_force
	state.apply_central_force(Vector3.UP * total_upward * mass)

func _is_on_floor() -> bool:
	if not floor_ray.is_colliding():
		return false
	else:
		return true

func _move() -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	var move_dir = Vector3(input_dir.x, 0, input_dir.y)
	apply_central_force(move_dir * move_speed * mass)

func _jump() -> void:
	if Input.is_action_just_pressed("jump") && _is_on_floor():
		apply_central_impulse(Vector3.UP * jump_impulse * mass)
