extends RigidBody3D

func _ready() -> void:
	if multiplayer.is_server():
		return
		constant_torque = Vector3(0, 8000.0, 0)

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		var server_transforms: Dictionary = {
			"rot": global_rotation
		}
		#client_receive_transforms.rpc(server_transforms)

@rpc("authority")
func client_receive_transforms(server_transforms: Dictionary) -> void:
	global_rotation = server_transforms["rot"]
