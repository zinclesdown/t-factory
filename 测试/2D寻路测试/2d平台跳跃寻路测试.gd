extends Node2D

@onready var 瓦片层: TileMapLayer = $TileMapLayer
@onready var AX := AStar2D.new() # 测试用寻路系统.

const GRID_SIZE := Vector2(32, 32)

const 默认允许坠落高度 := 8

func _ready() -> void:
	烘焙导航()
	_ready_调试()
	ImGuiGD.Connect(_imgui_调试面板)


func _process(_delta: float) -> void:
	queue_redraw()
	_process_测试角色移动路径()
	_imgui_检测瓦片属性()


func 获取瓦片数据(coord:Vector2i) -> TileData:
	return 瓦片层.get_cell_tile_data(coord)

#region 特异点相关

## 是梯子
func _瓦片是梯子(coord:Vector2i) -> bool:
	var 瓦片数据 := 获取瓦片数据(coord)
	return is_instance_valid(瓦片数据) and 瓦片数据.get_custom_data("梯子")

## 没有图块
func _瓦片不存在(coord:Vector2i) -> bool:
	return is_instance_valid(coord) == false

## 瓦片是可行走空间。包括【非占据空间】 和 【空白区域】
func _瓦片为有空间区域(coord:Vector2i) -> bool:
	var 瓦片数据 := 获取瓦片数据(coord)
	var 是空白 := is_instance_valid(瓦片数据) == false
	var 是非占据空间 :bool = _瓦片占据空间(coord)==false
	return 是空白 or 是非占据空间

## 瓦片上方不是梯子，下方有梯子，自己是梯子。
func _瓦片是梯子顶端(coord:Vector2i) -> bool:
	var 上方不是梯子 := _瓦片是梯子(coord + Vector2i.UP) == false
	var 下方是梯子 := _瓦片是梯子(coord + Vector2i.DOWN)
	var 自己是梯子 := _瓦片是梯子(coord)
	return 上方不是梯子 and 下方是梯子 and 自己是梯子

## 瓦片上方梯子，下方不是梯子，自己是梯子
func _瓦片是梯子底部(coord:Vector2i) -> bool:
	var 上方是梯子 := _瓦片是梯子(coord + Vector2i.UP)
	var 下方不是梯子 := _瓦片是梯子(coord + Vector2i.DOWN) == false
	var 自己是梯子 := _瓦片是梯子(coord)
	return 上方是梯子 and 下方不是梯子 and 自己是梯子

func _瓦片占据空间(coord:Vector2i) -> bool:
	var 瓦片数据 := 瓦片层.get_cell_tile_data(coord)
	return is_instance_valid(瓦片数据) and 瓦片数据.get_custom_data("占据空间")

## 瓦片位置\瓦片位置上方一格 是否有空间容纳2格高的人形角色. 不会考虑下方有没有图块.
func _瓦片位置有容纳人形空间(coord:Vector2i) -> bool:
	var 本体有空间 := _瓦片为有空间区域(coord)
	var 上方有空间 := _瓦片为有空间区域(coord + Vector2i.UP)
	return 本体有空间 and 上方有空间

## 瓦片位置可站立。该瓦片下方是否有占据空间？瓦片、瓦片上方一格是否有空间？
func _瓦片位置可站立(coord:Vector2i) -> bool:
	var 瓦片有空间区域 := _瓦片为有空间区域(coord)
	var 上方有空间区域 := _瓦片为有空间区域(coord+Vector2i.UP)
	var 下方有支撑 := _瓦片占据空间(coord+Vector2i.DOWN)
	return 瓦片有空间区域 and 上方有空间区域 and 下方有支撑


## 瓦片的正下方是否有支撑点？ 取决于下方有没有 【占据空间】图块。
func _瓦片正下方有支撑(coord:Vector2i) -> bool:
	return _瓦片占据空间(coord + Vector2i.DOWN)

## 瓦片是悬崖特殊点?
## 1. 本体可站立
## 2. 下方为实体区块
## 3. 左下方/右下方有至少一侧为空. 为空的一侧可跌落(正左方/正右方为 "可容纳人形空间")
func _瓦片是悬崖特异点(coord:Vector2i) -> bool:
	var 本体可站立 := _瓦片位置可站立(coord)
	var 左方可容纳   := _瓦片位置有容纳人形空间(coord + Vector2i.LEFT)
	var 左下方可容纳 := _瓦片位置有容纳人形空间(coord + Vector2i.DOWN + Vector2i.LEFT)
	var 右方可容纳   := _瓦片位置有容纳人形空间(coord + Vector2i.RIGHT)
	var 右下方可容纳 := _瓦片位置有容纳人形空间(coord + Vector2i.DOWN + Vector2i.RIGHT)
	return 本体可站立 and ((左下方可容纳 and 左方可容纳) or (右下方可容纳 and 右方可容纳))

## 瓦片是坠落特异点?
## 取决于范围内高处是否有悬崖特异点.
## 1. 该点可站立
## 2. 悬崖特异点到这个点的x距离为1
## 3. y方向差值少于3. 位置比悬崖点低.
## 4. 从该点到悬崖点之间的所有点,都必须是有容纳人形空间的点
func _瓦片是坠落特异点(coord:Vector2i, 坠落高度:=默认允许坠落高度) -> bool:
	if _瓦片位置可站立(coord) == false:
		return false
		
	for i:int in range(1, 坠落高度): # 搜索附近的悬崖. 假设遇到没有空间的区域,则停止搜索.
		if _瓦片为有空间区域(coord + Vector2i.UP*i) == false: return false ## 停止搜索.此时搜到了
		else: # 如果有空间,检测两侧是否是悬崖
			if _瓦片是悬崖特异点(coord + Vector2i.UP*i + Vector2i.LEFT) or _瓦片是悬崖特异点(coord + Vector2i.UP*i + Vector2i.RIGHT):
				return true
	return false


## 是梯子特异点?
## 限于梯子顶端上方和底端. 
## HACK FIXME 没有考虑到"上方被占据" 的情况!!!
func _瓦片是梯子特异点(coord:Vector2i) -> bool:
	var 是梯子顶端上方一格 := _瓦片是梯子顶端(coord + Vector2i.DOWN)
	var 是梯子底部 := _瓦片是梯子底部(coord)
	return 是梯子顶端上方一格 or 是梯子底部


## 是墙壁特异点?
## 本体位置可站立,左侧/右侧没有空间可用
func _瓦片是墙壁特异点(coord:Vector2i) -> bool:
	var 本体可站立 := _瓦片位置可站立(coord)
	var 左侧无空间 := _瓦片位置有容纳人形空间(coord + Vector2i.LEFT) == false
	var 右侧无空间 := _瓦片位置有容纳人形空间(coord + Vector2i.RIGHT) == false

	return 本体可站立 and (左侧无空间 or 右侧无空间)

#endregion


#region 特异点连接性相关

func _特异点_位于同一高度(coordA:Vector2i, coordB:Vector2i) -> bool:
	return coordA.y == coordB.y

## 排序特异点. 我们要求 特异点 先从左到右, 再从上到下 排列.
## 例如: (0, 0), (1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1), (3, 1)
func __特异点_排序位置函数(coordA:Vector2i, coordB:Vector2i) -> bool:
		if coordA.y == coordB.y: 
			return coordA.x < coordB.x
		else: 
			return coordA.y <= coordB.y


## 若两点位于同一高度, 两点之间全都是可行走点, 则我们认为这两点可建立双向连接. A在B左侧.
func _特异点_可建立平面行走双向连接(_coordA:Vector2i, _coordB:Vector2i) -> bool:
	if _特异点_位于同一高度(_coordA, _coordB)==false:  # 只有同一水平面才能连接
		return false
	if _coordA == _coordB: # 防止相同点
		return false
	
	var coordA := _coordA if __特异点_排序位置函数(_coordA, _coordB) else _coordB ## 确保A在B左侧
	var coordB := _coordB if __特异点_排序位置函数(_coordA, _coordB) else _coordA
	var dis :int = coordB.x - coordA.x
	
	# 需要确保所有点全部都是可行走点
	for i:int in range(0, dis+1):
		if _瓦片位置可站立(coordA + i*Vector2i.RIGHT) == false:
			return false
	return true


## 若两点x相差为1, y相差在8以内,则视为可以落下.
func _特异点_可从A到B直接落下(coordA_高处:Vector2i, coordB_低处:Vector2i, 最大下落范围:= 默认允许坠落高度) -> bool:
	if abs(coordA_高处.x - coordB_低处.x) != 1: # 首先排除"x相差不为1"
		return false
	if  coordB_低处.y <= coordA_高处.y: # 然后排除不在高处的情况
		return false
	if _瓦片位置可站立(coordA_高处)==false or _瓦片位置可站立(coordB_低处)==false: # 最后确保两点有效
		return false
	if _瓦片是悬崖特异点(coordA_高处) ==false: # 最后确保高处那个是悬崖特异点
		return false
	
	
	# 搜索悬崖.
	var 坠落高度 := coordB_低处.y - coordA_高处.y
	if 坠落高度 > 最大下落范围: # 防止高空坠落
		return false
	
	for i:int in range(1, 坠落高度): # 确保悬崖到自己之间有连接.
		if _瓦片为有空间区域(coordB_低处 + Vector2i.UP*i) == false: 
			return false # 假设中途卡着了,则不允许落下
	return true


## 最大跳跃高度:2格. 角色最高能跳自己身高一致的格子..
## FIXME HACK 注意!!!以下写法仅限 高度2 水平距离3 以内, 如果擅自改高,很容易穿帮!!!!!!
func _特异点_从A低处到B高处可跳跃_AB可以没有高度差(coordA_低:Vector2i, coordB_高:Vector2i)->bool: #,最大跳跃高度:=2, 最大跳跃水平距离:= 3):
	# 我们默认A是低点,B是高点
	
	# A必须在低, 否则退出
	if coordA_低.y < coordB_高.y:
		return false
	
	var A在左侧:= true if coordA_低.x < coordB_高.x else false
	
	
	# 默认A在左,B在右
	var 待检测点:Array[Vector2i] = []
	var 高度差 := absi(coordA_低.y - coordB_高.y)
	var 距离差 := absi(coordA_低.x - coordB_高.x)
	
	if not (高度差<=2 and 距离差<=3): # 高度距离差必须在范围内
		return false
	
	
	var 待检测点_相对数学坐标:Array
	## 此处使用数学坐标系,左为x正方向, 上为y正方向. A点位置为[0,0].
	## 这里涵盖了从 左侧低处 往 右侧高处 跳跃的表.
	## 假设是从 右侧低处 往 左侧高处 , 则需要翻转x. 使用翻转系数即可.
	
	if 高度差==0 and 距离差==2:
		待检测点_相对数学坐标=[[0,0], [1,0], [2,0]]
	elif 高度差==0 and 距离差==3:
		待检测点_相对数学坐标=[[0,0], [1,0], [2,0], [3,0]]
	elif 高度差==1 and 距离差==1:
		待检测点_相对数学坐标=[[0,0], [0,1], [1,1]]
	elif 高度差==1 and 距离差==2:
		待检测点_相对数学坐标=[[0,0], [1,1], [1,2]]
	elif 高度差==1 and 距离差==3:
		待检测点_相对数学坐标=[[0,0], [0,1], [1,1], [1,2], [1,3]]
		
	elif 高度差==2 and 距离差==1:
		待检测点_相对数学坐标=[[0,0], [0,1], [0,2], [1,2]]
	elif 高度差==2 and 距离差==2:
		待检测点_相对数学坐标=[[0,0], [0,1], [1,1], [1,2], [2,2]]
	elif 高度差==2 and 距离差==3:
		待检测点_相对数学坐标=[[0,0], [0,1], [0,2], [1,1], [1,2],[2,1], [2,2], [3,2]]
	else:
		return false
	
	# 接下来,转换数学坐标为屏幕坐标, 然后再转换为世界坐标, 添加到待监测点里.
	for math_coord:Array in 待检测点_相对数学坐标:
		var x_math :int= math_coord[0]
		var y_math :int= math_coord[1]
		var 翻转系数 := 1 if A在左侧 else -1 ## 翻转. 假设A在右侧B在左侧,也需要能正确处理跳跃.
		
		var 相对坐标 :Vector2i = Vector2i(x_math*翻转系数, -y_math)
		var 全局坐标 :Vector2i = 相对坐标 + coordA_低
		待检测点.append(全局坐标)
	
	
	# 最后,检测每个待监测点是否是"没问题的",即可.
	for coord:Vector2i in 待检测点:
		if _瓦片位置有容纳人形空间(coord) == false:
			return false
	return true


#endregion

func _imgui_检测瓦片属性():
	ImGui.Begin("瓦片属性")
	var coord := 瓦片层.local_to_map(get_global_mouse_position())
	ImGui.Text("位置： %s" % [coord])
	ImGui.Text("瓦片数据: %s" % [获取瓦片数据(coord)])
	ImGui.Text("占据空间: %s" % [_瓦片占据空间(coord)])
	ImGui.Text("是有空间区域： %s" % [_瓦片为有空间区域(coord)])
	ImGui.Text("位置可站立: %s" % [_瓦片位置可站立(coord)])
	ImGui.Text("正下方有支撑: %s" % [_瓦片正下方有支撑(coord)])
	ImGui.Text("是梯子: %s" % [_瓦片是梯子(coord)])
	ImGui.Text("是梯子顶部: %s" % [_瓦片是梯子顶端(coord)])
	ImGui.Text("是梯子底部: %s" % [_瓦片是梯子底部(coord)])
	ImGui.Text("_瓦片位置有容纳人形空间: %s" % [_瓦片位置有容纳人形空间(coord)])
	ImGui.Text("_瓦片是悬崖特异点: %s" % [_瓦片是悬崖特异点(coord)])
	ImGui.Text("_瓦片是梯子特异点: %s" % [_瓦片是梯子特异点(coord)])
	ImGui.Text("_瓦片是墙壁特异点: %s" % [_瓦片是墙壁特异点(coord)])
	ImGui.Text("_瓦片是坠落特异点: %s" % [_瓦片是坠落特异点(coord)])
	
	ImGui.End()



func 烘焙导航():
	AX.clear()
	var 特异点: Array[Vector2i] # 边缘, 可掉落点, 梯子的下方/上方, 斜坡的两侧(斜坡占据的点位)

	## 第一遍遍历: 寻找所有特异点
	for coord: Vector2i in 瓦片层.get_used_cells(): # 遍历所有点. 假设点属于导航特异点, 则将该点添加到图层里.
		## 规则1: 完整梯子的下方\和上方的一格 都是特异点.
		if _瓦片是梯子特异点(coord + Vector2i.UP):
			特异点.append(coord + Vector2i.UP)
			continue

		## 规则2: 悬崖点都是特异点. 遍历每一地基点, 如果该点 左侧\ 左侧往上一格\ 左侧往上两格 都为空, 才视为悬崖点.
		if _瓦片是悬崖特异点(coord + Vector2i.UP):
			特异点.append(coord + Vector2i.UP)
			continue

		## 规则3: 墙壁/阻挡物也是特异点. 包括 只有一格的通行点. (由于角色占据两格高度, 无法进入一格, 一格被视作墙壁.)
		if _瓦片是墙壁特异点(coord + Vector2i.UP):
			特异点.append(coord + Vector2i.UP)
			continue

		## 规则4: 可落地点也被视作特异点. 正常情况下, 我们允许角色跳下3格的悬崖
		if _瓦片是坠落特异点(coord + Vector2i.UP):
			特异点.append(coord + Vector2i.UP)
			continue

	## 排序特异点. 
	特异点.sort_custom(__特异点_排序位置函数)

	## 添加点到图里.
	for id: int in 特异点.size():
		AX.add_point(id, Vector2(特异点[id]))
	var 特异点ID表 := AX.get_point_ids()
	特异点ID表.sort()
	
	# 第二遍遍历: 连接特异点. 遍历每个特异点.
	for sourceID: int in 特异点ID表:
		var sourceCoord: Vector2i = AX.get_point_position(sourceID)
		

		for targetID in 特异点ID表:
			var targetCoord :Vector2i= AX.get_point_position(targetID)
			
			## 规则1: 如果两点y坐标相同, 且两点之间没有阻挡, 且两点之间正下方两点连线经过的所有方块都是被占据的空间/梯子,则建立双向连接.
			if _特异点_可建立平面行走双向连接(sourceCoord, targetCoord):
				AX.connect_points(sourceID, targetID, true)
		
			## 规则2: 关于"落下": 如果两点y坐标不同, x坐标差值为1, 且高处点到低处点没有阻挡, 则建立从高处点到低处点的单向连接. 这代表落下.
			if _特异点_可从A到B直接落下(sourceCoord, targetCoord):
				AX.connect_points(sourceID, targetID, false)
				
				
			if _特异点_从A低处到B高处可跳跃_AB可以没有高度差(sourceCoord, targetCoord):
				AX.connect_points(sourceID, targetID, true)
			
		## TODO 规则3: 关于 "跳跃": 同上, 但y坐标差值在2.1以内. (角色跳跃高度为2格, 也就是说玩家最多跨过2格的高度.) 建立双向连接.
		## 规则3.1 向右高处跳
		
		
		#for target_id: int in 特异点ID表:
			#var 目标点位置 := AX.get_point_position(target_id)
#
			## # 我们要确保: 1.y坐标不同, 2.x坐标差值为1, 3.高处点到低处点没有阻挡.
			#if 目标点位置.y-特异点位置.y > 0 and (目标点位置.y-特异点位置.y)<4.1  and round(目标点位置.x - 特异点位置.x)==-1: # y坐标相同, 且不是同一个点
				#print("判断连接:", id, " ", target_id)
#
				#var 迭代点_检测障碍物: Array[Vector2i] = []
#
				#var 待迭代_y := absi(roundi(目标点位置.y - 特异点位置.y))
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.UP)
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.UP + Vector2i.LEFT)
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.LEFT)
				#for i in 待迭代_y+1:
					#迭代点_检测障碍物.append(特异点位置 + Vector2i.LEFT + Vector2i.DOWN * i)
					## 迭代点_检测障碍物.append(Vector2i(特异点位置.x + 1, 特异点位置.y) + Vector2i.DOWN * i)
#
#
				#print("迭代点_检测障碍物: ", 迭代点_检测障碍物)
				## 开始检测
				#var 有障碍物阻挡: bool = false
				## 检测是否有墙壁阻拦
				#for 点: Vector2i in 迭代点_检测障碍物:
					#var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
					#if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == true: # 如果有阻挡物, 则跳过
						#有障碍物阻挡 = true
						#break
				#if 有障碍物阻挡 == false:
					#AX.connect_points(target_id, id, false) # 双向连接 # HACK 应该单向才对, 我们需要后期单独针对跳跃的情况进行处理.
				#break # 无论连接成功与否,我们只判断最近的右侧的那一个点, 防止重复连接.
#
		## 规则3.2 向左高处跳
		#for target_id: int in 特异点ID表:
			#var 目标点位置 := AX.get_point_position(target_id)
#
			## # 我们要确保: 1.y坐标不同, 2.x坐标差值为1, 3.高处点到低处点没有阻挡.
			#if 目标点位置.y-特异点位置.y > 0 and (目标点位置.y-特异点位置.y) <= 4.1 and round(目标点位置.x - 特异点位置.x)==1: # y坐标相同, 且不是同一个点
				#print("判断连接:", id, " ", target_id)
#
				#var 迭代点_检测障碍物: Array[Vector2i] = []
#
				#var 待迭代_y := absi(roundi(目标点位置.y - 特异点位置.y))
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.UP)
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.UP + Vector2i.RIGHT)
				#迭代点_检测障碍物.append(特异点位置 + Vector2i.RIGHT)
				#for i in 待迭代_y+1:
					#迭代点_检测障碍物.append(特异点位置 + Vector2i.RIGHT + Vector2i.DOWN * i)
				#print("迭代点_检测障碍物: ", 迭代点_检测障碍物)
				## 开始检测
				#var 有障碍物阻挡: bool = false
				## 检测是否有墙壁阻拦
				#for 点: Vector2i in 迭代点_检测障碍物:
					#var _检测瓦片数据 := 瓦片层.get_cell_tile_data(点)
					#if _检测瓦片数据 and _检测瓦片数据.get_custom_data("占据空间") == true: # 如果有阻挡物, 则跳过
						#有障碍物阻挡 = true
						#break
				#if 有障碍物阻挡 == false:
					## print("连接点: ", id, " ", target_id)
					#AX.connect_points(target_id, id, false) # 双向连接 # HACK
				#break # 无论连接成功与否,我们只判断最近的右侧的那一个点, 防止重复连接.
#
		## TODO 规则4: 关于 "梯子": 如果x相同,y不同, 中间的节点全是梯子, 则建立梯子的双向连接.
		#for target_id: int in 特异点ID表:
			#var 自己位置   :Vector2 = AX.get_point_position(id)
			#var 目标点位置 :Vector2 = AX.get_point_position(target_id)

			# 规则1: 完整梯子的下方\和上方的一格 都是特异点.
			# 如果自己是“完整的梯子的上方”， 则尝试与完整梯子下方建立双向连接

			
			#if 是梯子 == true:
				#if 上方是梯子 == true and 下方是梯子 == false: # 该点上方是梯子, 下方不是梯子: 则属于梯子底端, 是特异点.
					#特异点.append(coord)
					#continue
				#if 上方是梯子 == false and 下方是梯子 == true: # 该点上方不是梯子, 下方是梯子: 则属于梯子顶端, 是特异点.
					#特异点.append(coord + Vector2i.UP)
					#continue

	# for id in ids:
		# print("连接: " , id, ": ", "pos:", AX.get_point_position(id)  ,"  ", AX.get_point_connections(id))
		# pass


	# 最后，进行映射。
	# 将map(Vec2i) 映射到 world(Vec2)
	for id: int in 特异点.size():
		#AX.add_point(id, Vector2(特异点[id]))
		AX.set_point_position(id, AX.get_point_position(id) * GRID_SIZE + GRID_SIZE/2.0)


func _draw() -> void:
	for id: int in AX.get_point_ids(): # 遍历所有ID
		# 先绘制所有点
		var coord: Vector2 = AX.get_point_position(id)
		draw_circle(coord,  6, Color.GREEN)
		
		# 然后绘制该点的连接。
		for 被连接点的ID: int in AX.get_point_connections(id):
			var 被连接点的坐标: Vector2 = AX.get_point_position(被连接点的ID)
			
			# 绘制连接线
			var 起点位置 := coord
			var 终点位置 := 被连接点的坐标
			var 是双向连接 :bool= (id in AX.get_point_connections(被连接点的ID))
			var 颜色 := Color.AQUA if 是双向连接 else Color.YELLOW
			
			draw_line(coord, 终点位置, 颜色, 2.0)
			
			if not 是双向连接:
				# 从线终点绘制三角形，表示连接方向
				var 方向向量 := (终点位置-起点位置).normalized()
				var 箭头线长 := 30.0
				
				var 箭头线1终点 := 箭头线长 * 方向向量.rotated(PI * ( 19.0/20.0)) + 终点位置
				var 箭头线2终点 := 箭头线长 * 方向向量.rotated(PI * (-19.0/20.0)) + 终点位置
				draw_polygon([箭头线1终点, 箭头线2终点, 终点位置],[颜色])


	# 鼠标到最近点
	draw_line(
		get_global_mouse_position(), 
		AX.get_point_position(AX.get_closest_point(get_global_mouse_position())), Color.WHITE, 1.0)

	# 鼠标到最近线段
	draw_line(
		get_global_mouse_position(), 
		AX.get_closest_position_in_segment(get_global_mouse_position()),
		Color.WHITE, 1.0)

	# 绘制示例角色位置
	draw_circle(测试角色位置, 16.0, Color.GREEN)

	# 绘制图块
	var rect := Rect2(瓦片层.map_to_local(瓦片层.local_to_map(get_global_mouse_position()))-GRID_SIZE/2.0, GRID_SIZE)
	draw_rect(rect, Color.RED, false, 1.0)

func _ready_调试() -> void:
	var 随机初始id :int = Array(AX.get_point_ids()).pick_random()
	var 随机位置 :Vector2 = AX.get_point_position(随机初始id)
	测试角色位置 = 随机位置


func _imgui_调试面板():
	ImGui.Begin("寻路调试")
	ImGui.TextWrapped("位置: " + str(测试角色位置))
	ImGui.TextWrapped("移动队列：" + str(测试角色移动队列))
	ImGui.End()


var 测试角色位置 := Vector2.ZERO
var 测试角色移动队列 := []


func _input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# TEST 实现寻路。
		var 鼠标最近ID :=  AX.get_closest_point(get_global_mouse_position())
		var 测试角色最近ID := AX.get_closest_point(测试角色位置)
		print("尝试移动角色到 ID:[%s] 位置" % [鼠标最近ID])
		
		var 路径 := AX.get_id_path(测试角色最近ID, 鼠标最近ID, true)
		测试角色移动队列 = 路径
		print(路径)


func _process_测试角色移动路径():
	if 测试角色移动队列.size()>=2:
		测试角色位置.x = move_toward(测试角色位置.x, AX.get_point_position(测试角色移动队列[1]).x, 3.0)
		测试角色位置.y = move_toward(测试角色位置.y, AX.get_point_position(测试角色移动队列[1]).y, 3.0)
		
		if 测试角色位置.distance_to(AX.get_point_position(测试角色移动队列[1])) <= 1.0:
			测试角色移动队列.pop_at(0)
