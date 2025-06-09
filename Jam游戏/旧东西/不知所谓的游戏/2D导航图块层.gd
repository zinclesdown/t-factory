extends TileMapLayer
class_name 平面导航图块层


@export var 瓦片层: TileMapLayer = self
@onready var AX := AStar2D.new() # 测试用寻路系统.

@export var GRID_SIZE := Vector2(32, 32)
@export var 默认允许坠落高度 := 8

func _ready() -> void:
	print(瓦片层)
