@tool
extends EditorPlugin

# A class member to hold the control during the plugin life cycle.
var control

# TODO: Add seperate scene for creating, loading and importing mods
func _enter_tree():
	print("mod_tool loaded")
	# Initialization of the plugin goes here.
	# Load the control scene and instantiate it.
	control = preload("res://addons/hwtycoon_modtool/mod_tool.tscn").instantiate()
	
	# Add the loaded scene to the docks.
	add_control_to_bottom_panel(control,"Mod Tool")


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the control.
	remove_control_from_bottom_panel(control)
	# Erase the control from the memory.
	control.free()
	print("mod_tool unloaded")
