extends Node

const MAIN = "menu_main"
const LOBBY = "menu_lobby"
const LOBBY_V2 = "level_lobby"
const SETTINGS = "menu_settings"
const PAUSE = "menu_pause"

var active_menu_node = null
var active_menu_path = null

func _ready() -> void:
	Helper.log(self, "Ready")
	var main_menu = load("res://scenes/menu_main.tscn").instantiate()
	add_child(main_menu)
	if not active_menu_node: active_menu_node = main_menu
	if not active_menu_path: active_menu_path = MAIN

@rpc("authority", "call_local", "reliable")
func process_join() -> void:
	Helper.log(self, "Processing join")
	#load_menu(LOBBY)
	ManagerLevel.load_level(ManagerLevel.LEVEL_LOBBY)

@rpc("authority", "call_local", "reliable")
func load_menu(menu_path: String) -> void:
	## If target menu is already active
	if menu_path == active_menu_path: 
		Helper.log(self, "Menu already active")
		active_menu_node.visible = not active_menu_node.visible
		#match active_menu_path:
			#PAUSE:
				#active_menu_node.visible = not active_menu_node.visible
		return
	
	active_menu_node.queue_free()
	var menu_node = load("res://scenes/%s.tscn" % menu_path).instantiate()
	await get_tree().process_frame
	add_child(menu_node)
	active_menu_path = menu_path
	active_menu_node = menu_node

@rpc("authority", "call_local", "reliable")
func hide_active_menu() -> void:
	active_menu_node.hide()

func quit_to_main() -> void:
	Helper.log(self, "Quit to main menu")
	load_menu(MAIN)
	if multiplayer.is_server():
		ManagerNetwork.shutdown_server()
	else:
		ManagerNetwork.shutdown_client()

@rpc("authority", "call_local", "reliable")
func quit_to_lobby() -> void:
	Helper.log(self, "Quit to lobby")
	
	for replicate_node in get_tree().get_nodes_in_group("replicate"):
		replicate_node.queue_deletion()
	
	ManagerLevel.clear_level()
	load_menu(LOBBY)
