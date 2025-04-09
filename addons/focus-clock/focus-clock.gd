@tool
extends EditorPlugin

var clock:Control

const CLOCK_TSCN := preload("./clock.tscn")

func _enter_tree() -> void:
	get_editor_interface().get_editor_main_screen()
	clock = CLOCK_TSCN.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, clock)
	#add_control_to_dock(DOCK_SLOT_RIGHT_BL, clock)

func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, clock)
	#remove_control_from_docks(clock)
	clock.queue_free()
