extends Node3D

@onready var controller = get_parent() as Node3D

var follow_speed:float	= 20.0
var turn_speed: float	= 10.0

var controller_prev_transform_basis: Basis

var target_basis: Basis

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	top_level = true

func _process(delta: float) -> void:
	_handle_position(delta * follow_speed)
	_handle_rotation_match_move_dir(delta * turn_speed)

func _physics_process(_delta: float) -> void:
	controller_prev_transform_basis = controller.global_transform.basis

func _handle_position(delta) -> void:
	global_position = global_position.lerp(controller.global_position, delta)

func _handle_rotation_match_camera(delta) -> void:
	if not controller_prev_transform_basis: return
	
	var q_prev = controller_prev_transform_basis.get_rotation_quaternion()
	var q_curr = controller.global_transform.basis.get_rotation_quaternion()
	var smooth_q = q_prev.slerp(q_curr, delta).normalized()
	
	# Strip everything except yaw
	var euler = smooth_q.get_euler()
	var yaw_only_q = Quaternion.from_euler(Vector3(0, euler.y, 0))
	
	global_transform.basis = Basis(yaw_only_q)

func _handle_rotation_match_move_dir(delta) -> void:
	if not controller_prev_transform_basis: return
	if controller.move_dir_3d == Vector3.ZERO: return
	target_basis = Basis.looking_at(controller.move_dir_3d, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, delta)
