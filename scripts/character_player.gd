extends RigidBody3D

# Hover
@onready var hover_ray: RayCast3D = %HoverRay
var hover_height: float = 1.5
var hover_force: float = 100.0
var hover_damping: float = 10.0

# Floor
@onready var floor_ray: RayCast3D = %FloorRay

# Move
var move_speed: float = 100.0

# Jump
var jump_impulse: float = 20.0

func _ready() -> void:
	print("Player spawned")
	
	if multiplayer.is_server(): return
	%Controller.set_multiplayer_authority(int(self.name))

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		var server_transforms: Dictionary = {
			"pos": global_position
		}
		#client_receive_transforms.rpc(server_transforms)
	elif is_multiplayer_authority():
		pass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_hover(state)

func _hover(state: PhysicsDirectBodyState3D) -> void:
	if not is_on_floor(): return
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

@rpc("authority")
func client_receive_transforms(server_transforms: Dictionary) -> void:
	global_position = server_transforms["pos"]
