extends Node3D

@export var focus: Node

var mouse_sensitivity: float	= 0.1
var twist_input: float 			= 0.0
var pitch_input: float			= 0.0

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if focus == null: return
	
	global_position = global_position.lerp(
		focus.global_position, delta * 2.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate_camera(event)

func _rotate_camera(event: InputEventMouseMotion) -> void:
	twist_input -= event.relative.x * mouse_sensitivity
	pitch_input -= event.relative.y * mouse_sensitivity
	pitch_input = clamp(pitch_input, -89, 89)
	basis = _quat_rotate(twist_input, pitch_input)

func _quat_rotate(twist, pitch) -> Basis:
	var twist_quat = Quaternion(Vector3.UP, deg_to_rad(twist))
	var pitch_quat = Quaternion(Vector3.RIGHT, deg_to_rad(pitch))
	return Basis(twist_quat * pitch_quat)
