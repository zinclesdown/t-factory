extends Node2D

@onready var 瓦片层: TileMapLayer = $TileMapLayer

const GRID_SIZE := Vector2(32, 32)

# 测试用寻路系统.
@onready var AX := AStar2D.new()


func _ready() -> void:
	#AX. add_point(1, Vector2(0,0))
	#AX. add_point(2, Vector2(1,0))
	#AX. add_point(3, Vector2(2,0))
	#AX. add_point(4, Vector2(2,1))
	#AX. add_point(5, Vector2(3,0))
#
	#
	#AX.connect_points(1, 2)
	#AX.connect_points(2, 3)
	#AX.connect_points(3, 4)
	#AX.connect_points(3, 5)
	pass
	烘焙导航()

func _process(_delta: float) -> void:
	queue_redraw()


func 烘焙导航():
	# clear
	AX.clear()
	
	
	#var 可导航点 :Array[Vector2i]
	var 特异点: Array[Vector2i] # 边缘, 可掉落点, 梯子的下方/上方, 斜坡的两侧(斜坡占据的点位)

	var space_state := get_world_2d().get


	# 第一遍遍历: 寻找所有特异点
	for coord: Vector2i in 瓦片层.get_used_cells(): # 遍历所有点(的上方). 假设点可以被导航, 则将该点添加到图层里.
		# 首先,确认该点是不是梯子节点.
		var 瓦片数据 := 瓦片层.get_cell_tile_data(coord)
		var 上方瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.UP)
		var 上上方瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.UP + Vector2i.UP)
		var 下方瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.DOWN)
		var 左方瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.LEFT)
		var 右方瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.RIGHT)
		
		var 左下瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.LEFT + Vector2i.DOWN)
		var 右下瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.RIGHT + Vector2i.DOWN)
		
		
		var 左上瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.LEFT + Vector2i.UP)
		var 左上上瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.LEFT + Vector2i.UP + Vector2i.UP)
		var 右上瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.RIGHT + Vector2i.UP)
		var 右上上瓦片数据 := 瓦片层.get_cell_tile_data(coord + Vector2i.RIGHT + Vector2i.UP + Vector2i.UP)


		var 上方是梯子: bool = 上方瓦片数据.get_custom_data("梯子") if 上方瓦片数据 else false
		var 下方是梯子: bool = 下方瓦片数据.get_custom_data("梯子") if 下方瓦片数据 else false
		
		var 上方占据空间: bool = 上方瓦片数据.get_custom_data("占据空间") if 上方瓦片数据 else false
		var 上上方占据空间: bool = 上上方瓦片数据.get_custom_data("占据空间") if 上上方瓦片数据 else false
	 
		var 左方占据空间: bool = 左方瓦片数据.get_custom_data("占据空间") if 左方瓦片数据 else false
		var 右方占据空间: bool = 右方瓦片数据.get_custom_data("占据空间") if 右方瓦片数据 else false

		var 左上方占据空间: bool = 左上瓦片数据.get_custom_data("占据空间") if 左上瓦片数据 else false
		var 右上方占据空间: bool = 右上瓦片数据.get_custom_data("占据空间") if 右上瓦片数据 else false

		var 左上上方占据空间: bool = 左上上瓦片数据.get_custom_data("占据空间") if 左上上瓦片数据 else false
		var 右上上方占据空间: bool = 右上上瓦片数据.get_custom_data("占据空间") if 右上上瓦片数据 else false


		var 是梯子: bool = 瓦片数据.get_custom_data("梯子") if 瓦片数据 else false
		var 占据空间: bool = 瓦片数据.get_custom_data("占据空间") if 瓦片数据 else false


		# 规则1: 完整梯子的下方\和上方的一格 都是特异点.
		if 是梯子 == true:
			if 上方是梯子 == true and 下方是梯子 == false: # 该点上方是梯子, 下方不是梯子: 则属于梯子底端, 是特异点.
				特异点.append(coord)
				continue
			if 上方是梯子 == false and 下方是梯子 == true: # 该点上方不是梯子, 下方是梯子: 则属于梯子顶端, 是特异点.
				特异点.append(coord + Vector2i.UP)
				continue
		

		# 规则2: 悬崖点都是特异点. 遍历每一地基点, 如果该点 左侧\ 左侧往上一格\ 左侧往上两格 都为空, 才视为悬崖点.
		# 补充规则: 可落地点也被视作特异点. 正常情况下, 我们允许角色跳下6格的悬崖
		if 占据空间 and 上方占据空间 == false and 上上方占据空间 == false and 左方占据空间 == false and 左上方占据空间 == false and 左上上方占据空间 == false: # 左侧为空的悬崖
			特异点.append(coord + Vector2i.UP)
			# 向左下探测, 如果有可落地点, 则添加. 我们通过判断左下方的点是否占据空间来判断是否是可落地点.
			for i: int in 6:
				var 正在探测的瓦片的偏移 := Vector2i.LEFT + Vector2i.DOWN * i
				var _探测左下方瓦片数据 := 瓦片层.get_cell_tile_data(coord + 正在探测的瓦片的偏移)
				if _探测左下方瓦片数据 and _探测左下方瓦片数据.get_custom_data("占据空间") == true:
					特异点.append(coord + 正在探测的瓦片的偏移 + Vector2i.UP)
					break
			continue

		if 占据空间 and 上方占据空间 == false and 上上方占据空间 == false and 右方占据空间 == false and 右上方占据空间 == false and 右上上方占据空间 == false: # 右侧为空的悬崖
			特异点.append(coord + Vector2i.UP)
			# 向右下探测, 如果有可落地点, 则添加. 我们通过判断右下方的点是否占据空间来判断是否是可落地点.
			for i: int in 6:
				var 正在探测的瓦片的偏移 := Vector2i.RIGHT + Vector2i.DOWN * i
				var _探测右下方瓦片数据 := 瓦片层.get_cell_tile_data(coord + 正在探测的瓦片的偏移)
				if _探测右下方瓦片数据 and _探测右下方瓦片数据.get_custom_data("占据空间") == true:
					特异点.append(coord + 正在探测的瓦片的偏移 + Vector2i.UP)
					break
			continue


		# 规则3: 墙壁/阻挡物也是特异点. 包括 只有一格的通行点. (由于角色占据两格高度, 无法进入一格, 一格被视作墙壁.)
		if 占据空间 and 上方占据空间 == false and 上上方占据空间 == false and (左上方占据空间 == true or 左上上方占据空间 == true): # 左侧是墙壁
			特异点.append(coord + Vector2i.UP)
			continue
		if 占据空间 and 上方占据空间 == false and 上上方占据空间 == false and (右上方占据空间 == true or 右上上方占据空间 == true): # 右侧是墙壁
			特异点.append(coord + Vector2i.UP)
			continue

	# 排序特异点.
	# 我们要求 特异点 先从左到右, 再从上到下 排列.
	# 例如: (0, 0), (1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1), (3, 1)
	特异点.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		else:
			return a.y <= b.y
	)




	# 添加点
	print("特异点: ", 特异点)
	for id: int in 特异点.size():
		AX.add_point(id, 特异点[id])



	var ids := AX.get_point_ids()
	ids.sort()

	print(ids)


	# 第二遍遍历: 连接特异点
	for id: int in ids:
		# 对于每个特异点:
		var 特异点位置: Vector2i = AX.get_point_position(id)
		
		# 规则1: 如果两点y坐标相同, 且两点之间没有阻挡, 且两点之间正下方两点连线经过的所有方块都是被占据的空间/梯子,则建立双向连接.
		# 一旦与最近的点建立了连接, 就会终止当前这个点的[左右侧连接]遍历,防止过度浪费性能.
		for target_id: int in ids:
			var 目标点位置 := AX.get_point_position(target_id)
				
			# if 目标点位置.y != 特异点位置.y or 目标点位置.x <= 特异点位置.x: # y坐标相同, 且不是同一个点
			if 目标点位置.y != 特异点位置.y or 目标点位置.x <= 特异点位置.x: # y坐标相同, 且不是同一个点
				continue
			if target_id <= id: # y坐标相同, 且不是同一个点
				continue # 不是同一行的点, 跳过.

			# print("判断连接:", id, " ", target_id)


			# 迭代, 检测两点所占据空间内是否有阻挡. 
			# 例如, 假设两点位于 (0,0), (3,0), 则我们需要检测(0,0), (1,0), (2,0), (3,0), (0,1), (1,1), (2,1), (3,1) 这8个点.
			# 这是确保高度为2的角色可以通过这两点.
			var 迭代点_检测为空: Array[Vector2i] = []
			var 迭代点_检测支撑: Array[Vector2i] = []


			var 待迭代_i := roundi(目标点位置.x - 特异点位置.x)

			for i: int in 待迭代_i + 1:
				迭代点_检测为空.append(Vector2i(特异点位置.x + i, 特异点位置.y))
				迭代点_检测为空.append(Vector2i(特异点位置.x + i, 特异点位置.y) + Vector2i.UP)
				迭代点_检测支撑.append(Vector2i(特异点位置.x + i, 特异点位置.y) + Vector2i.DOWN)
			
			# print("迭代点_检测为空: ", 迭代点_检测为空)
			# print("迭代点_检测支撑: ", 迭代点_检测支撑)
			
			# 开始检测
			var 有障碍物阻挡: bool = false
			var 有支撑点: bool = true
			
			# 检测是否有墙壁阻拦
			for 点: Vector2i in 迭代点_检测为空:
				var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
				if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == true: # 如果有阻挡物, 则跳过
					有障碍物阻挡 = true
			
			# 检测是否有支撑点
			for 点: Vector2i in 迭代点_检测支撑:
				var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
				
				if is_instance_valid(_检测瓦片数据) == false: # 如果没有支撑点, 则跳过
					有支撑点 = false
					break
				
				if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == false: # 如果无法支撑, 则跳过
					有支撑点 = false
					break
				

			# 最后根据结果进行连接.
			if 有障碍物阻挡 == false and 有支撑点 == true:
				AX.connect_points(id, target_id, true)
				# print("连接点: ", id, " ", target_id)

			else:
				# print("连接点失败: ", id, " ", target_id)
				pass


			# AX.connect_points(id, subid, true) # 双向连接
			
			break # 无论连接成功与否,我们只判断最近的右侧的那一个点, 防止重复连接.


		# TEST
		# 规则2: 关于"落下": 如果两点y坐标不同, x坐标差值为1, 且高处点到低处点没有阻挡, 则建立从高处点到低处点的单向连接. 这代表落下.
		# 规则2.1 向左落下:
		for target_id: int in ids:
			var 目标点位置 := AX.get_point_position(target_id)

			# # 我们要确保: 1.y坐标不同, 2.x坐标差值为1, 3.高处点到低处点没有阻挡.
			if 目标点位置.y > 特异点位置.y and round(目标点位置.x - 特异点位置.x)==-1: # y坐标相同, 且不是同一个点
				print("判断连接:", id, " ", target_id)

				var 迭代点_检测障碍物: Array[Vector2i] = []

				var 待迭代_y := absi(roundi(目标点位置.y - 特异点位置.y))
				迭代点_检测障碍物.append(特异点位置 + Vector2i.UP)
				迭代点_检测障碍物.append(特异点位置 + Vector2i.UP + Vector2i.LEFT)
				迭代点_检测障碍物.append(特异点位置 + Vector2i.LEFT)
				for i in 待迭代_y+1:
					迭代点_检测障碍物.append(特异点位置 + Vector2i.LEFT + Vector2i.DOWN * i)
					# 迭代点_检测障碍物.append(Vector2i(特异点位置.x + 1, 特异点位置.y) + Vector2i.DOWN * i)


				print("迭代点_检测障碍物: ", 迭代点_检测障碍物)
				# 开始检测
				var 有障碍物阻挡: bool = false
				# 检测是否有墙壁阻拦
				for 点: Vector2i in 迭代点_检测障碍物:
					var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
					if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == true: # 如果有阻挡物, 则跳过
						有障碍物阻挡 = true
						break
				if 有障碍物阻挡 == false:
					# print("连接点: ", id, " ", target_id)
					AX.connect_points(id, target_id, true) # 双向连接 # HACK 应该单向才对, 我们需要后期单独针对跳跃的情况进行处理.
				break # 无论连接成功与否,我们只判断最近的右侧的那一个点, 防止重复连接.

		# 规则2.2 向右落下:
		for target_id: int in ids:
			var 目标点位置 := AX.get_point_position(target_id)

			# # 我们要确保: 1.y坐标不同, 2.x坐标差值为1, 3.高处点到低处点没有阻挡.
			if 目标点位置.y > 特异点位置.y and round(目标点位置.x - 特异点位置.x)==1: # y坐标相同, 且不是同一个点
				print("判断连接:", id, " ", target_id)

				var 迭代点_检测障碍物: Array[Vector2i] = []

				var 待迭代_y := absi(roundi(目标点位置.y - 特异点位置.y))
				迭代点_检测障碍物.append(特异点位置 + Vector2i.UP)
				迭代点_检测障碍物.append(特异点位置 + Vector2i.UP + Vector2i.RIGHT)
				迭代点_检测障碍物.append(特异点位置 + Vector2i.RIGHT)
				for i in 待迭代_y+1:
					迭代点_检测障碍物.append(特异点位置 + Vector2i.RIGHT + Vector2i.DOWN * i)
					# 迭代点_检测障碍物.append(Vector2i(特异点位置.x + 1, 特异点位置.y) + Vector2i.DOWN * i)
				print("迭代点_检测障碍物: ", 迭代点_检测障碍物)
				# 开始检测
				var 有障碍物阻挡: bool = false
				# 检测是否有墙壁阻拦
				for 点: Vector2i in 迭代点_检测障碍物:
					var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
					if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == true: # 如果有阻挡物, 则跳过
						有障碍物阻挡 = true
						break
				if 有障碍物阻挡 == false:
					# print("连接点: ", id, " ", target_id)
					AX.connect_points(id, target_id, true) # 双向连接 # HACK
				break # 无论连接成功与否,我们只判断最近的右侧的那一个点, 防止重复连接.

		
		# TODO 规则3: 关于 "跳跃": 同上, 但y坐标差值在3以内. (角色跳跃高度为2.5格, 也就是说玩家最多跨过2格的高度.) 建立双向连接.
		# TODO 规则4: 关于 "梯子": 如果x相同,y不同, 中间的节点全是梯子, 则建立梯子的双向连接.



	# for id in ids:
		# print("连接: " , id, ": ", "pos:", AX.get_point_position(id)  ,"  ", AX.get_point_connections(id))
		# pass
	
func _draw() -> void:
	for id: int in AX.get_point_ids():
		var coord: Vector2 = AX.get_point_position(id)
		draw_circle(coord * GRID_SIZE + GRID_SIZE / 2, 8, Color.GREEN)
		
		for connected_point_id: int in AX.get_point_connections(id):
			var connected_coord: Vector2 = AX.get_point_position(connected_point_id)
			
			draw_line(coord * GRID_SIZE + GRID_SIZE / 2, connected_coord * GRID_SIZE + GRID_SIZE / 2, Color.AQUA, 2.0)
