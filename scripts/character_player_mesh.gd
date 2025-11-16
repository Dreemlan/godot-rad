extends Node3D

@onready var body = get_parent() as RigidBody3D

var body_prev_transform_basis: Basis

func _ready() -> void:
	if multiplayer.is_server(): return
	top_level = true

func _process(_delta: float) -> void:
	if ManagerNetwork.is_server(): return
	
	var interp_frac = Engine.get_physics_interpolation_fraction()
	
	global_position = global_position.lerp(body.global_position, interp_frac)
	
	if not body_prev_transform_basis: return
	var q_prev = body_prev_transform_basis.get_rotation_quaternion()
	var q_curr = body.global_transform.basis.get_rotation_quaternion()
	var smooth_q = q_prev.slerp(q_curr, interp_frac).normalized()
	global_transform.basis = Basis(smooth_q)

func _physics_process(_delta: float) -> void:
	body_prev_transform_basis = body.global_transform.basis
