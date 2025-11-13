extends RigidBody3D

var rpc_enabled: bool = false

func _ready() -> void:
	if multiplayer.is_server():
		return
		#constant_torque = Vector3(0, 8000.0, 0)
	else:
		enable_rpc.rpc_id(1, true)

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		var server_transforms: Dictionary = {
			"rot": global_rotation
		}
		if not rpc_enabled: return
		client_receive_transforms.rpc(server_transforms)

@rpc("any_peer", "reliable")
func enable_rpc(state: bool) -> void:
	Helper.log(self, "Enable RPC")
	rpc_enabled = state

@rpc("authority")
func client_receive_transforms(server_transforms: Dictionary) -> void:
	global_rotation = server_transforms["rot"]
