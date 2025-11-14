extends Node

const MAIN = "menu_main"
const LOBBY = "menu_lobby"
const SETTINGS = "menu_settings"
const PAUSE = "menu_pause"

var active_menu_node = null
var active_menu_path = null
var inactive_menu_path_map = {}
var inactive_menu_node_map = {}

var is_ingame: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")
	var main_menu = load("res://scenes/menu_main.tscn").instantiate()
	add_child(main_menu)
	if not active_menu_node: active_menu_node = main_menu
	if not active_menu_path: active_menu_path = MAIN

@rpc("authority", "call_local", "reliable")
func load_menu(menu_path: String) -> void:
	# If target menu is already active
	if menu_path == active_menu_path: 
		Helper.log(self, "Menu already active")
		match active_menu_path:
			PAUSE:
				active_menu_node.visible = not active_menu_node.visible
		return
	# Begin swapping to a new menu
	# Store it in inactive
	if not inactive_menu_path_map.has(active_menu_path):
		Helper.log(self, "Hide active menu node")
		inactive_menu_path_map.set(active_menu_path, active_menu_node)
		inactive_menu_node_map.set(active_menu_node, active_menu_path)
		active_menu_node.queue_free()
	# If the target menu already exists but is inactive
	if inactive_menu_path_map.has(menu_path):
		Helper.log(self, "Show active menu node")
		active_menu_path = menu_path
		active_menu_node = inactive_menu_path_map[active_menu_path]
		active_menu_node.show()
	else:
		active_menu_node.hide()
		Helper.log(self, "Add new menu node")
		var menu_node = load("res://scenes/%s.tscn" % menu_path).instantiate()
		await get_tree().process_frame
		add_child(menu_node)
		active_menu_path = menu_path
		active_menu_node = menu_node
	
	#Helper.log(self, "Added '%s' to scene tree" % active_menu)
	#Helper.log(self, "%s" % [active_menu])

@rpc("authority", "call_local", "reliable")
func hide_active_menu() -> void:
	active_menu_node.hide()

func quit_to_main(prev_menu) -> void:
	Helper.log(self, "Quit to main menu")
	# Queue free all menus except the main menu
	await get_tree().process_frame
	#inactive_menu_node_map.set(prev_menu)
	#prev_menu.queue_free()
	
	load_menu(MAIN)
	#
	#var menu_path = inactive_menu_node_map[prev_menu]
	#inactive_menu_path_map
	#
	#active_menu_path = MAIN
	#active_menu_node = inactive_menu_path_map[active_menu_path]
	
	#for menu in inactive_menus:
		#print(menu)
		#if not menu == MAIN:
			#var menu_node = inactive_menus[menu]
			#menu_node.queue_free()
	
	#active_menu_node.show()
	NetworkManager.shutdown_server()
