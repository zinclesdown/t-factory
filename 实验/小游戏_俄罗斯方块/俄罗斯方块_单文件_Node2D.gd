extends Node2D
class_name 俄罗斯方块游戏场景实例

var 当前方块矩阵: Array[Array] = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
	[0, 0, 1, 0, 1, 2, 0, 0, 0, 0, 0, 0],
	[0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

var 当前活动方块: Array[Array] = []

enum { 空 = 0, 红 = 1, 黄 = 2, 蓝 = 3 }

const 当前方块大小 := Vector2(24, 24)

var 当前地图大小_getter :Vector2i:
	get:
		if 当前方块矩阵.size() != 0:
			return Vector2i(当前方块矩阵.size(), 当前方块矩阵[0].size())
		else:
			return Vector2i.ZERO


func _tick_游戏帧():
	## 读取 当前方块矩阵 和 当前活动方块。
	## 两者是尺寸相同的矩阵。我们根据当前活动方块矩阵的值，判断活动矩阵下方有无阻碍。
	## 若没有，活动下移1；
	## 若有，活动矩阵数据写入当前矩阵， 然后清空自己，重新检索。
	
	var 下方有障碍物 := false
	
	# 仅检测是否有障碍物。 
	for x in 当前活动方块.size():
		for y in 当前活动方块[0].size():
			if 当前活动方块[x][y] != 空: # 若有方块
				# 若触底
				if y == 当前地图大小_getter.y - 1:
					下方有障碍物 = true
					break
				# 若正下方有方块
				elif 当前方块矩阵[x][y+1] != 空:
					下方有障碍物 = true
					break
	
	# 根据结果判断
	if 下方有障碍物:
		for x in 当前地图大小_getter.x:
			for y in 当前地图大小_getter.y:
				当前方块矩阵[x][y] = 当前活动方块[x][y] # 写入
				当前活动方块[x][y] = 0 # 重置当前方块
	
	# TODO
	# 如果没有触底，则试图往下一格。
	else:
		pass
		# TODO 把 当前活动方块 矩阵，全部往下移动一格。
	
	
	# 接下来，判断削去规则。在这里判断
	var 可消去行 :Array[int]=[]
	for x in 当前地图大小_getter.x:
		var 可消去 := true
		
		for y in 当前地图大小_getter.y: # 确保一行全不是空
			if 当前方块矩阵[x][y] == 空:
				可消去=false
		
		if 可消去: # 如果存在不为空的行，
			可消去行.append(x)

	
	# 接下来，一步一步按照消去表，把行削下来。
	# TODO



func _draw_绘制网格():
	for x in 当前地图大小_getter.x:
		for y in 当前地图大小_getter.y:
			var value: int = 当前方块矩阵[x][y]
			var color := _enum_to_color(value)

			draw_rect(Rect2(Vector2(y, x) * 当前方块大小, 当前方块大小), color, true, -1.0, false)


func _enum_to_color(color: int) -> Color:
	if color == 空:
		return Color.BLACK
	elif color == 红:
		return Color.RED
	elif color == 黄:
		return Color.YELLOW
	elif color == 蓝:
		return Color.BLUE
	else:
		return Color.TRANSPARENT


## 绘制方块
func _draw() -> void:
	_draw_绘制网格()


func _on_tick_pressed() -> void:
	_tick_游戏帧()
