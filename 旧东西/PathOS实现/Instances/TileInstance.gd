class_name TileInstance extends Instance

@export var tileInfo: TileInfo


var mapBelongsTo :MapInstance

### Get Local Coord.
#func getPositionInMap() -> Vector2i:
	#mapBelongsTo.getTilePosition(self)
	#pass
