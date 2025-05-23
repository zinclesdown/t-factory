extends Node2D

@onready var 瓦片层: TileMapLayer = $TileMapLayer
@onready var AX := AStar2D.new() # 测试用寻路系统.

@export var GRID_SIZE := Vector2(32, 32)
@export var 默认允许坠落高度 := 8


var 测试角色位置 := Vector2.ZERO
var 测试角色移动队列 := []
var 测试角色精确目的地 := Vector2.ZERO ## 精确的,两个ID之间的目的地.

#var 当前移动类型


func 获取吸附到网格中心后点(local_pos:Vector2) -> Vector2:
	return 瓦片层.map_to_local(瓦片层.local_to_map(local_pos))

func 获取Map坐标(local_pos:Vector2) -> Vector2i:
	return 瓦片层.local_to_map(local_pos)

func 获取ID位置(点:int)->Vector2:
	return AX.get_point_position(点)


enum Enum移动方式 {
	水平移动,
	跳跃移动,
	攀爬梯子,
}


func Enum移动方式_to_string(枚举值:Enum移动方式)->String:
	match 枚举值:
		Enum移动方式.水平移动:
			return "水平移动"
		Enum移动方式.跳跃移动:
			return "跳跃移动"
		Enum移动方式.攀爬梯子:
			return "攀爬梯子"
		_:
			assert(false, "错误!")
			return "错误!!!"
	
## 根据点1到点2,获取移动方式,从而获取该播放的动画. 
## TEST 不确定这么写有没有问题
func 获取点到点移动方式(点1_开始:int, 点2_结束:int) -> Enum移动方式:
	var 位置1 :Vector2 = 获取ID位置(点1_开始)
	var 位置2 :Vector2 = 获取ID位置(点2_结束)
	var dir := 位置2 - 位置1
	
	## 水平跳跃.
	if dir.y == 0: ## 水平移动
		
		# 假设两点之间可以行走,则行走
		return Enum移动方式.水平移动
		
		var coord1 := 瓦片层.local_to_map(位置1)
		if _瓦片是悬崖特异点(coord1):
			return Enum移动方式.跳跃移动
		else:
			return Enum移动方式.水平移动
		
	elif dir.y != 0 and dir.x == 0: ## 竖直移动. 目前有且只有跳跃一条方法.
		return Enum移动方式.攀爬梯子
	else: ## 竖直移动. 目前有且只有跳跃一条方法.
		return Enum移动方式.跳跃移动


func _ready() -> void:
	烘焙导航()
	_ready_调试()



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
	var 自己是梯子 := _瓦片是梯子(coord)
	return 上方不是梯子  and 自己是梯子

## 瓦片上方梯子，下方不是梯子，自己是梯子
func _瓦片是梯子底部(coord:Vector2i) -> bool:
	var 下方不是梯子 := _瓦片是梯子(coord + Vector2i.DOWN) == false
	var 自己是梯子 := _瓦片是梯子(coord)
	return 下方不是梯子 and 自己是梯子

func _瓦片占据空间(coord:Vector2i) -> bool:
	var 瓦片数据 := 瓦片层.get_cell_tile_data(coord)
	return is_instance_valid(瓦片数据) and 瓦片数据.get_custom_data("占据空间")

## 瓦片位置\瓦片位置上方一格 是否有空间容纳2格高的人形角色. 不会考虑下方有没有图块.
func _瓦片位置有容纳人形空间(coord:Vector2i) -> bool:
	var 本体有空间 := _瓦片为有空间区域(coord)
	var 上方有空间 := _瓦片为有空间区域(coord + Vector2i.UP)
	return 本体有空间 and 上方有空间

## 瓦片位置可站立。该瓦片下方是否有占据空间？瓦片、瓦片上方一格是否有空间？ 梯子也是可以站立的.
func _瓦片位置可站立(coord:Vector2i) -> bool:
	var 瓦片有空间区域 := _瓦片为有空间区域(coord)
	var 上方有空间区域 := _瓦片为有空间区域(coord+Vector2i.UP)
	var 下方有支撑 := _瓦片占据空间(coord+Vector2i.DOWN)
	var 下方是梯子 := _瓦片是梯子(coord + Vector2i.DOWN)
	var 当前是梯子 := _瓦片是梯子(coord)
	return 瓦片有空间区域 and 上方有空间区域 and (下方有支撑 or 下方是梯子 or 当前是梯子)


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


func _瓦片是梯子特异点(coord:Vector2i) -> bool:
	var 是梯子 := _瓦片是梯子(coord)
	var 自己以及上方一格有空间 := _瓦片位置有容纳人形空间(coord)
	return (是梯子 and 自己以及上方一格有空间) 
	
	#var 是梯子底部 := _瓦片是梯子底部(coord)
	#return 是梯子顶端上方一格 or 是梯子底部

	# 所有梯子节点 和 上方一格 都是潜在的特异点.只要该梯子所在位置上方和上上方都可以正常站立即可.

func _瓦片是梯子上方一格的特异点(coord:Vector2i) -> bool:
	var 是梯子顶端上方一格 := _瓦片是梯子顶端(coord + Vector2i.DOWN)
	var 上方及上方一格有容纳空间 := _瓦片位置有容纳人形空间(coord)
	return (是梯子顶端上方一格 and 上方及上方一格有容纳空间) 

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


func _特异点_AB之间是直接垂直相连的梯子_没有其他梯子(coordA:Vector2i, coordB:Vector2i) -> bool:
	if coordA.x != coordB.x:
		return false
	if absi(coordA.y - coordB.y) != 1:
		return false 
	return true

#endregion

var _imgui状态 := "瓦片调试"

func _imgui_检测瓦片属性()->void:
	if Engine.has_singleton("ImGuiAPI"):
		@warning_ignore("shadowed_global_identifier")
		var ImGui: Object = Engine.get_singleton("ImGuiAPI")

		ImGui.Begin("瓦片属性", [], ImGui.WindowFlags_MenuBar)
		var coord := 瓦片层.local_to_map(get_global_mouse_position())
		
		ImGui.BeginMenuBar()
		if ImGui.MenuItem("瓦片调试"):
			_imgui状态 = "瓦片调试"
		if ImGui.MenuItem("其他调试"):     
			_imgui状态 = "其他调试"
		ImGui.EndMenuBar()

		if _imgui状态 == "瓦片调试":
			if ImGui.CollapsingHeader("属性相关", ImGui.TreeNodeFlags_DefaultOpen):
				ImGui.Text("位置： %s" % [coord])
				ImGui.Text("瓦片数据: %s" % [获取瓦片数据(coord)])
				ImGui.Text("占据空间: %s" % [_瓦片占据空间(coord)])
				ImGui.Text("是有空间区域： %s" % [_瓦片为有空间区域(coord)])
				ImGui.Text("位置可站立: %s" % [_瓦片位置可站立(coord)])
				ImGui.Text("正下方有支撑: %s" % [_瓦片正下方有支撑(coord)])
				ImGui.Text("是梯子: %s" % [_瓦片是梯子(coord)])
				ImGui.Text("是梯子顶部: %s" % [_瓦片是梯子顶端(coord)])
				ImGui.Text("是梯子底部: %s" % [_瓦片是梯子底部(coord)])
				ImGui.Text("位置有容纳人形空间: %s" % [_瓦片位置有容纳人形空间(coord)])
			
			if ImGui.CollapsingHeader("特异点相关", ImGui.TreeNodeFlags_DefaultOpen):
				ImGui.Text("_瓦片是悬崖特异点: %s" % [_瓦片是悬崖特异点(coord)])
				ImGui.Text("_瓦片是梯子特异点: %s" % [_瓦片是梯子特异点(coord)])
				ImGui.Text("_瓦片是梯子上方一格的特异点: %s" % [_瓦片是梯子上方一格的特异点(coord)])
				ImGui.Text("_瓦片是墙壁特异点: %s" % [_瓦片是墙壁特异点(coord)])
				ImGui.Text("_瓦片是坠落特异点: %s" % [_瓦片是坠落特异点(coord)])
			
			if ImGui.CollapsingHeader("导航相关", ImGui.TreeNodeFlags_DefaultOpen):
				ImGui.SeparatorText("导航信息")
				ImGui.Text("测试角色位置 %s" % [测试角色位置])
				ImGui.Text("移动数组： %s" % [测试角色移动队列])

			ImGui.Text("尚未抵达目的地: %s" % [尚未抵达目的地()])
			ImGui.Text("目的地是特异点: %s" % [目的地是特异点()])
			ImGui.Text("角色当前路径位于两水平连接特异点之间: %s" % [角色当前路径位于两水平连接特异点之间()])
			
			
			if 测试角色移动队列.size() >= 2:
				ImGui.Text("当前角色移动状态: %s" % [Enum移动方式_to_string(获取点到点移动方式(测试角色移动队列[0], 测试角色移动队列[1]))])
			else:
				ImGui.Text("当前没有在移动")
				
			if ImGui.Button("烘焙导航"):
				烘焙导航()
		
		ImGui.End()




func 烘焙导航()->void:
	AX.clear()
	var 特异点: Array[Vector2i] # 边缘, 可掉落点, 梯子的下方/上方, 斜坡的两侧(斜坡占据的点位)

	## 第一遍遍历: 寻找所有特异点
	for coord: Vector2i in 瓦片层.get_used_cells(): # 遍历所有点. 假设点属于导航特异点, 则将该点添加到图层里.

		## 规则1: 能容纳角色的梯子是特异点.
		var 是梯子有关特异点_tmp := false
		if _瓦片是梯子特异点(coord):
			特异点.append(coord)
			是梯子有关特异点_tmp= true
		if _瓦片是梯子上方一格的特异点(coord + Vector2i.UP):
			特异点.append(coord + Vector2i.UP)
			是梯子有关特异点_tmp= true
		if 是梯子有关特异点_tmp==true:
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
				
			## 规则3: 关于 "跳跃": 同上, 但y坐标差值在2.1以内. (角色跳跃高度为2格, 也就是说玩家最多跨过2格的高度.) 建立双向连接.
			if _特异点_从A低处到B高处可跳跃_AB可以没有高度差(sourceCoord, targetCoord):
				AX.connect_points(sourceID, targetID, true)
			
			## 规则4: 梯子是连接的特异点.
			if _特异点_AB之间是直接垂直相连的梯子_没有其他梯子(sourceCoord, targetCoord):
				AX.connect_points(sourceID, targetID, true)

	# 最后，进行映射。
	# 将map(Vec2i) 映射到 world(Vec2)
	for id: int in 特异点.size():
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

	
	 
	
	draw_line(
		get_global_mouse_position(), 
		获取最近可行目的地(get_global_mouse_position())
		, Color.WHITE, 1.0)

	
	## 鼠标到最近点
	#draw_line(
		#get_global_mouse_position(), 
		#AX.get_point_position(AX.get_closest_point(get_global_mouse_position())), Color.WHITE, 1.0)
#
	## 鼠标到最近线段
	#draw_line(
		#get_global_mouse_position(), 
		#AX.get_closest_position_in_segment(get_global_mouse_position()),
		#Color.WHITE, 1.0)

	# 绘制示例角色位置
	draw_circle(测试角色位置, 16.0, Color.GREEN)

	# 绘制图块
	var rect := Rect2(瓦片层.map_to_local(瓦片层.local_to_map(get_global_mouse_position()))-GRID_SIZE/2.0, GRID_SIZE)
	draw_rect(rect, Color.RED, false, 1.0)


	# 绘制目的地.
	if 测试角色移动队列.size() >= 1:
		var 位置 := 获取ID位置(测试角色移动队列.back())
		draw_circle(位置, 12.0 + sin(Engine.get_frames_drawn() * 0.05), Color.BLUE)
		
	# 绘制精确目的地
	if 测试角色移动队列.size() >= 1:
		draw_circle(测试角色精确目的地, 12.0 + sin(Engine.get_frames_drawn() * 0.05), Color.AQUA)
		

func _ready_调试() -> void:
	var 随机初始id :int = Array(AX.get_point_ids()).pick_random()
	var 随机位置 :Vector2 = AX.get_point_position(随机初始id)
	测试角色位置 = 随机位置


#var 测试角色移动目标中途地点 := Vector2.ZERO ## 目的地.
#var 测试角色移动点1 := Vector2.ZERO # 离最近的两点
#var 测试角色移动点2 := Vector2.ZERO


## 假设角色想去某个点, 我们该把 "精确目的地" 安排在哪里呢?
## 如果目的地点是"悬空"的,那么会改为选择最近特异点;
## 如果不是悬空,我们则放置在两点之间连线上.
## TEST
func 获取最近可行目的地(pos:Vector2) -> Vector2:
	## 首先获取目的地(离指令最近位置)是否可站立.根据该信息判断具体怎么走.
	
	var 最近coord := 瓦片层.local_to_map(AX.get_closest_position_in_segment(pos))
	if _瓦片位置可站立(最近coord):
		# 可站立. 我们可以选择两点中点作为目的地.
		#print("瓦片可站立")
		return 获取吸附到网格中心后点(AX.get_closest_position_in_segment(pos))
	else:
		# 不可站立. 我们只能选择最近特异点.
		#print("瓦片不可站立")
		return AX.get_point_position(AX.get_closest_point(pos))
		

func _input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# TEST 实现寻路。
		var 鼠标位置 := get_global_mouse_position()
		
		var 鼠标最近ID :=  AX.get_closest_point(鼠标位置)
		var 测试角色最近ID := AX.get_closest_point(测试角色位置)
		print("尝试移动角色到 ID:[%s] 位置" % [鼠标最近ID])
		
		var 路径 := AX.get_id_path(测试角色最近ID, 鼠标最近ID, true)
		测试角色移动队列 = 路径
		print(路径)
		
		测试角色精确目的地 = 获取最近可行目的地(AX.get_closest_position_in_segment(鼠标位置))


func 目的地是特异点() -> bool:
	if 测试角色移动队列.size()>=1:
		return 测试角色精确目的地 == 获取ID位置(测试角色移动队列.back())
	else:
		return false


func 尚未抵达目的地() -> bool:
	if 测试角色移动队列.size() <= 0:  ## "未初始化" 被视为 "以抵达目的地"
		return false 
	
	# 目的地不是特异点,我们根据最终位置判断
	if 目的地是特异点() == false:
		var 到精确目的地的距离 := (测试角色精确目的地 - 测试角色位置).length()
		if 到精确目的地的距离 <= 3.0: # 抵达目的地
			return false
		else:
			return true
	
	# 目的地是特异点,我们根据数组大小判断.
	if 目的地是特异点():
		if 测试角色移动队列.size() >= 1:
			return true
		else:
			return false
	return false


func 角色当前路径位于两水平连接特异点之间()->bool:
	if 测试角色移动队列.size()<=1:
		return false
	
	# var 最近点 := AX.get_closest_point(测试角色位置)
	var 第一点 :Vector2 = AX.get_point_position(测试角色移动队列[0]) 
	var 第二点 :Vector2 = AX.get_point_position(测试角色移动队列[1]) 
	
	if _特异点_可建立平面行走双向连接(获取Map坐标(第一点), 获取Map坐标(第二点)):
		return true
	else:
		return false

# var _临时特异点 :Array[int] = []

## BROKEN FIXME 这个方法没有被正确实现!!!
func _process_测试角色移动路径():
	# const MOVE_SPEED := 1.0
	# const POINT_POP_DISTANCE := 2.0
	pass
	#AX.get_point_connections()
	#
	#if 角色当前路径位于两水平连接特异点之间():
		#测试角色移动队列.pop_front()
	#
	#if 尚未抵达目的地() and 目的地是特异点()==true:
		#if 测试角色移动队列.size()>=1:
			#var dir :Vector2 = (AX.get_point_position(测试角色移动队列[0])-测试角色位置).normalized()
			#测试角色位置 += dir * MOVE_SPEED
#
		## 如果抵达一个点,则将该点弹出.
		#if 测试角色位置.distance_to(AX.get_point_position(测试角色移动队列[0])) <= POINT_POP_DISTANCE:
			#测试角色移动队列.pop_at(0)
			#
		## 如果抵达了终点,则弹出其他所有点.
		#if 测试角色位置.distance_to(测试角色精确目的地) <= POINT_POP_DISTANCE:
			#print("抵达目的地!")
			#测试角色移动队列 = []
#
	#if 尚未抵达目的地() and 目的地是特异点()==false:
		#if 测试角色移动队列.size() >=2 or (测试角色移动队列.size()==1 and abs(测试角色位置.y-测试角色精确目的地.y)>2.0): # 如果有两个或更多点,则按照特异点的情况处理.
			#var dir :Vector2 = (AX.get_point_position(测试角色移动队列[0])-测试角色位置).normalized()
			#测试角色位置 += dir * MOVE_SPEED
			## 如果抵达一个点,则将该点弹出.
			#if 测试角色位置.distance_to(AX.get_point_position(测试角色移动队列[0])) <= POINT_POP_DISTANCE:
				#测试角色移动队列.pop_at(0)
#
			#if 测试角色位置.distance_to(测试角色精确目的地) <= POINT_POP_DISTANCE:
				#测试角色移动队列 = []
		#
		#elif 测试角色移动队列.size() == 1 : # 如果有最后一个点, 且该点与目的地y坐标相同, 我们则要根据特异点进行移动.
			## 直接移动到目标地点
			#var dir :Vector2 = (测试角色精确目的地-测试角色位置).normalized()
			#测试角色位置 += dir * MOVE_SPEED
			#
			#if 测试角色位置.distance_to(测试角色精确目的地) <= POINT_POP_DISTANCE:
				#测试角色移动队列 = []
