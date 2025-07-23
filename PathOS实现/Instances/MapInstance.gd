class_name MapInstance extends Instance

var tiles: Array[TileInstance] = [] ## Things that contributes to a whole world.
var mobs: Array[MobInstance] = [] ## Player/NPC is also an mob.
var positions: Dictionary[TileInstance, Vector2i] = {} ## This shows pos of a tile.

var tileSize := Vector2i(32, 32) # Tile size of the map.


## Get A specified tile.
func getTilePosition(tile: TileInstance) -> Vector2i:
	return positions.get(tile, null)


## TEST
## Draw tiles to node. Using multiple Sprite2Ds.
## NEEDS TO BE TESTED!
func renderToNode(rootNode: Node) -> void:

	# Clear root node.
	rootNode.get_children().all(func(a: Node) -> bool: a.queue_free();return true)

	for tileIns: TileInstance in tiles:
		# create sprite2D.
		var sprite := Sprite2D.new()
		sprite.texture = tileIns.tileInfo.texture
		sprite.centered = false

		# Put sprite2d into scene.
		sprite.position = getTilePosition(tileIns) * tileSize

		rootNode.add_child(sprite)


func _to_string() -> String:
	return "<MapInstance: #%5d>" % hash(self)
