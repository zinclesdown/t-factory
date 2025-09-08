class_name PathOSGame
extends Node

@export var renderMountpoint: Node

var curMap: MapInstance


func _ready() -> void:
	curMap = MapInstance.new()
	renderMap(curMap)


var imguiVars := {posAddTileInput_X=[0], posAddTileInput_Y=[0]}
func _process(delta: float) -> void:
	pass
	ImGui.Begin("GD")
	ImGui.InputInt("X", imguiVars["posAddTileInput_X"])
	ImGui.InputInt("Y", imguiVars["posAddTileInput_Y"])
	if ImGui.Button("Render a block!"):
		
		# Adds a tile.
		# POS:
		curMap.addTileAt(preload("res://PathOS实现/Infos/TileInfo/TestBlock.tres"), Vector2i(1,2))
		renderMap(curMap)
	ImGui.End()


func renderMap(mapIns: MapInstance):
	print("Render started!s")
	mapIns.renderToNode(renderMountpoint)


## Player moves -> 1 tick.
func _tick() -> void:

	pass
