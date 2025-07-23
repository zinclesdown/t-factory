class_name PathOSGame
extends Node


var curMap :MapInstance

@export var renderMountpoint :Node



func _ready() -> void:
	curMap = MapInstance.new()
	renderMap(curMap)


func renderMap(mapIns:MapInstance):
	

	
	print(mapIns)



## Player moves -> 1 tick.
func _tick() -> void:
	
	pass
