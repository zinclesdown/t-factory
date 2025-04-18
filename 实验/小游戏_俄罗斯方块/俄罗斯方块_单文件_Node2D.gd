extends Node2D

var 当前方块矩阵: Array[Array] = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
]

var 当前活动方块: Array[Array] = []

enum { 空 = 0, 红 = 1, 黄 = 2, 蓝 = 3 }

const 当前方块大小 := Vector2(24, 24)

var 当前地图大小_getter: Vector2i:
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
			if 当前活动方块[x][y] != 空:  # 若有方块
				# 若触底
				if x == 当前地图大小_getter.x - 1:
					下方有障碍物 = true
					break
				# 若正下方有方块
				elif 当前方块矩阵[x + 1][y] != 空:
					下方有障碍物 = true
					break

	# 根据结果判断
	if 下方有障碍物:
		for x in 当前地图大小_getter.x:
			for y in 当前地图大小_getter.y:
				if 当前活动方块[x][y] != 0:
					当前方块矩阵[x][y] = 当前活动方块[x][y]  # 写入
					当前活动方块[x][y] = 0  # 重置当前方块

		# 如果有障碍物，则放置后， 开始新的方块
		_重置当前活动方块()

	# 如果没有触底，则试图往下一格。
	else:
		var new_row := []
		new_row.resize(当前活动方块[0].size())
		new_row.fill(0)
		当前活动方块.insert(0, new_row)
		当前活动方块.pop_back()

	# 接下来，一步一步按照消去表，把行削下来。
	# TEST ME
	for x in 当前地图大小_getter.x:
		for r_index in 当前方块矩阵.size():
			if 当前方块矩阵[r_index].all(func(a): return a != 空):
				当前方块矩阵.remove_at(r_index)

				var new_row := []
				new_row.resize(当前活动方块[0].size())
				new_row.fill(0)
				当前方块矩阵.insert(0, new_row)

				break


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_left"):
		var 可以左移 := true
		for x in 当前地图大小_getter.x:
			if 可以左移 == false:  # 找到了不符合条件的部分，就不需要在继续判断了
				break
			for y in 当前地图大小_getter.y:
				# 判断左边触边
				if 当前活动方块[x][y] != 空 and y == 0:
					可以左移 = false
					break
				# 判断左边接触
				if 当前活动方块[x][y] != 空 and 当前方块矩阵[x][y - 1] != 空:
					可以左移 = false
					break
		if 可以左移:
			for x in 当前地图大小_getter.x:
				#for y in 当前地图大小_getter.y:
				当前活动方块[x].push_back(0)
				当前活动方块[x].pop_front()

	if Input.is_action_pressed("ui_right"):
		var 可以右移 := true
		for x in 当前地图大小_getter.x:
			if 可以右移 == false:  # 找到了不符合条件的部分，就不需要在继续判断了
				break
			for y in 当前地图大小_getter.y:
				# 判断右边触边
				if 当前活动方块[x][y] != 空 and y == 当前地图大小_getter.y - 1:
					可以右移 = false
					break
				# 判断左边接触
				if 当前活动方块[x][y] != 空 and 当前方块矩阵[x][y + 1] != 空:
					可以右移 = false
					break
		if 可以右移:
			for x in 当前地图大小_getter.x:
				#for y in 当前地图大小_getter.y:
				当前活动方块[x].push_front(0)
				当前活动方块[x].pop_back()

	if Input.is_action_just_pressed("ui_down"):
		_tick_游戏帧()


func _ready() -> void:
	# 重置当前活动方块
	_重置当前活动方块()


func _重置当前活动方块():
	# 重置为空
	当前活动方块 = []
	for x in 当前地图大小_getter.x:
		当前活动方块.append([])
		for y in 当前地图大小_getter.y:
			当前活动方块.back().append(0)

	_随机设置当前活动方块()


func _随机设置当前活动方块():
	var 可能的方块: Array[Array] = [
		[
			[1, 1],
			[1, 1],
		],
		[
			[1, 0],
			[1, 0],
			[1, 1],
		],
		[
			[0, 1],
			[0, 1],
			[1, 1],
		],
		[
			[0, 1, 0],
			[1, 1, 1],
		],
		[
			[1],
			[1],
			[1],
			[1],
		],
	]

	var 当前选中的方块: Array = 可能的方块.pick_random()
	var 选中方块的大小 := Vector2i(当前选中的方块.size(), 当前选中的方块[0].size())

	# 补全大小：
	for x in 当前地图大小_getter.x:
		for y in 当前地图大小_getter.y:
			var v_offset: int = floori((当前地图大小_getter.y - 选中方块的大小.y) / 2.0)

			if y - v_offset >= 0 and y - v_offset < 选中方块的大小.y and x < 选中方块的大小.x:
				当前活动方块[x][y] = 当前选中的方块[x][y - v_offset]
			else:
				当前活动方块[x][y] = 0


func _draw_绘制网格():
	for x in 当前地图大小_getter.x:
		for y in 当前地图大小_getter.y:
			var value: int = 当前方块矩阵[x][y]
			var color := _enum_to_color(value)
			draw_rect(Rect2(Vector2(y, x) * 当前方块大小, 当前方块大小), color, true, -1.0, false)

			var value2: int = 当前活动方块[x][y]
			var color2 := _enum_to_color(value2)
			draw_rect(Rect2(Vector2(y, x) * 当前方块大小 + Vector2(512, 0), 当前方块大小), color2, true, -1.0, false)


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


func _process(_delta: float) -> void:
	queue_redraw()

	if Input.is_action_pressed("ui_down"):
		_tick_游戏帧()


func _on_timer_timeout() -> void:
	_tick_游戏帧()  # Replace with function body.
