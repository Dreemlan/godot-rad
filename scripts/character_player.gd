extends RigidBody3D

var rpc_enabled: bool = false
var queued_for_delete: bool = false

# Hover
@onready var hover_ray: RayCast3D = %HoverRay
var hover_height: float = 1.5
var hover_force: float = 100.0
var hover_damping: float = 10.0

# Floor
@onready var floor_ray: RayCast3D = %FloorRay

# Move
var move_speed: float = 50.0

# Jump
var jump_impulse: float = 25.0

signal player_spawned(id: int)

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	%Controller.set_multiplayer_authority(int(self.name))
	
	if multiplayer.is_server():
		pass
	else:
		toggle_rpc.rpc_id(1, true)
	
	%FloatingNameLabel.text = ManagerPlayer.players[int(self.name)]["display_name"]
	
	player_spawned.emit(int(self.name))

func _exit_tree() -> void:
	Helper.log(self, "Exit tree")

@rpc("any_peer", "call_local", "reliable")
func queue_deletion() -> void:
	Helper.log(self, "Queued for deletion")
	toggle_rpc(false)
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		var server_transforms: Dictionary = {
			"pos": global_position
		}
		if not rpc_enabled: return
		#for p in ManagerPlayer.fully_loaded_players:
			#client_receive_transforms.rpc_id(p, server_transforms)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_hover(state)

func _hover(state: PhysicsDirectBodyState3D) -> void:
	if not is_on_floor():
		linear_damp = 0.0
		return
	linear_damp = 4.0
	if not hover_ray.is_colliding(): return
	
	var hit: Vector3 = hover_ray.get_collision_point()
	var height: float = state.transform.origin.y - hit.y
	var displacement: float = height - hover_height
	var spring_force: float = -hover_force * displacement
	var damping_force: float = -hover_damping * state.linear_velocity.y
	var total_upward: float = spring_force + damping_force
	state.apply_central_force(Vector3.UP * total_upward * mass)

func is_on_floor() -> bool:
	if not floor_ray.is_colliding():
		return false
	else:
		return true

@rpc("any_peer", "call_local", "reliable")
func toggle_rpc(state: bool) -> void:
	rpc_enabled = state
	var id: int = multiplayer.get_remote_sender_id()
	if ManagerPlayer.fully_loaded_players.has(id): return
	ManagerPlayer.fully_loaded_players.append(id)

@rpc("authority", "call_local", "unreliable")
func client_receive_transforms(server_transforms: Dictionary) -> void:
	if multiplayer.is_server(): return
	global_position = server_transforms["pos"]
