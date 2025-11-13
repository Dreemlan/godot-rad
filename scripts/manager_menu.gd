extends Node

const MAIN = preload("uid://t4j5kau1g2k5")
const LOBBY = preload("uid://wmgmxeoc70em")

var active_menu = null
var inactive_menus = []

func _ready() -> void:
	Helper.log(self, "Ready")
	var main_menu = load("res://scenes/menu_main.tscn").instantiate()
	add_child(main_menu)
	if not active_menu: active_menu = main_menu

@rpc("authority", "call_local", "reliable")
func load_menu(target_menu: PackedScene) -> void:
	if target_menu == active_menu: return
	
	if not inactive_menus.has(active_menu):
		inactive_menus.append(active_menu)
		active_menu.hide()
	
	if inactive_menus.has(target_menu):
		active_menu = target_menu
		active_menu.show()
	else:
		var new_menu = target_menu.instantiate()
		add_child(new_menu)
		active_menu = new_menu
	
	Helper.log(self, "Added '%s' to scene tree" % active_menu)

@rpc("authority", "call_local", "reliable")
func hide_active_menu() -> void:
	active_menu.hide()

func quit_to_main(prev_menu) -> void:
	Helper.log(self, "%s" % prev_menu)
	if inactive_menus.has(prev_menu): 
		Helper.log(self, "%s" % prev_menu)
		inactive_menus.erase(prev_menu)
	prev_menu.queue_free()
	load_menu(MAIN)
	NetworkManager.shutdown_server()
