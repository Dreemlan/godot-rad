extends Node

@onready var body = get_parent() as RigidBody3D

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	_move()
	_jump()

func _move() -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	var move_dir = Vector3(input_dir.x, 0, input_dir.y)
	body.apply_central_force(move_dir * body.move_speed * body.mass)

func _jump() -> void:
	if Input.is_action_just_pressed("jump") && body.is_on_floor():
		body.apply_central_impulse(Vector3.UP * body.jump_impulse * body.mass)
