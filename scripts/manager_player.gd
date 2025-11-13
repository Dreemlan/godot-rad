extends Node

# Player
const PLAYER = preload("res://scenes/character_player.tscn")
var players: Dictionary[int, Dictionary] = {}

var spawn_points = null

func _ready() -> void:
	Helper.log(self, "Ready")

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, display_name: String) -> void:
	if players.has(id): return
	players[id] = { "display_name": display_name }
	
	if multiplayer.is_server():
		for player in PlayerManager.players:
			add_player.rpc_id(id, player, players[multiplayer.get_unique_id()]["display_name"])
		add_player.rpc(id, display_name)
	if id == multiplayer.get_unique_id():
		MenuManager.load_menu(MenuManager.LOBBY)
	
	Helper.log(self, "Registered 'Player' %s to 'Dictionary'" % [id])

@rpc("any_peer", "call_local", "reliable")
func remove_player(id: int) -> void:
	ScoreManager.remove_player_score(id)
	despawn_player(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int) -> void:
	if has_node(str(id)): return
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	add_child(inst)
	Helper.log(self, "Added 'Player' %s to scene tree" % id)

func despawn_player(id: int) -> void:
	players.erase(id)
	if not has_node(str(id)): return
	get_node(str(id)).call_deferred("queue_free")

func spawn_all_players() -> void:
	if multiplayer.is_server():
		for id in players:
			spawn_player.rpc(id)

@rpc("any_peer", "reliable")
func confirm_player_spawn() -> void:
	pass
