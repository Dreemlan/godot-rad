extends Node

const MAIN = "menu_main"
const LOBBY = "menu_lobby"
const SETTINGS = "menu_settings"
const PAUSE = "menu_pause"

var active_menu_node = null
var active_menu_path = null

var is_ingame: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")
	var main_menu = load("res://scenes/menu_main.tscn").instantiate()
	add_child(main_menu)
	if not active_menu_node: active_menu_node = main_menu
	if not active_menu_path: active_menu_path = MAIN

@rpc("authority", "call_local", "reliable")
func load_menu(menu_path: String) -> void:
	## If target menu is already active
	if menu_path == active_menu_path: 
		Helper.log(self, "Menu already active")
		match active_menu_path:
			PAUSE:
				active_menu_node.visible = not active_menu_node.visible
		return
	
	active_menu_node.queue_free()
	Helper.log(self, "Add new menu node")
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
	await get_tree().process_frame
	load_menu(MAIN)
	if NetworkManager.is_server():
		NetworkManager.shutdown_server()
	else:
		NetworkManager.shutdown_client()
