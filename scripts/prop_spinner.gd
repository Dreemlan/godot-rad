extends RigidBody3D

var rpc_enabled: bool = false

func _ready() -> void:
	if multiplayer.is_server():
		constant_torque = Vector3(0, 8000.0, 0)
	else:
		toggle_rpc.rpc_id(1, true)

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		var server_transforms: Dictionary = {
			"rot": global_rotation
		}
		if not rpc_enabled: return
		client_receive_transforms.rpc(server_transforms)

@rpc("any_peer", "call_local", "reliable")
func toggle_rpc(state: bool) -> void:
	Helper.log(self, "@rpc %s" % state)
	rpc_enabled = state

@rpc("any_peer", "call_local", "reliable")
func queue_deletion() -> void:
	Helper.log(self, "Queued for deletion")
	toggle_rpc(false)
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")

@rpc("authority")
func client_receive_transforms(server_transforms: Dictionary) -> void:
	global_rotation = server_transforms["rot"]
