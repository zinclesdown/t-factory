# DungeonGenerator.gd
# Godot GDScript版本的地牢生成器
# 
# 这是一个基于GDScript 4.x的高性能Roguelike风格地牢生成器，采用数据驱动架构设计。
# 核心算法包括BSP树空间分割、Kruskal最小生成树房间连接、L型走廊生成等。
# 
# 主要特性：
# - 数据驱动架构：所有状态和配置都可序列化为JSON
# - 高性能算法：基于BSP树和最小生成树的高效地牢生成
# - 模块化设计：每个组件职责单一，便于维护和扩展
# - 完整的错误处理：使用枚举定义错误类型，便于调试
# - 统计信息：提供详细的生成统计和性能指标
# 
# @author Claude Code
# @version 2.1
# @date 2025-09-01

@tool
extends RefCounted
class_name DungeonGenerator

# ===========================================
# 错误类型枚举
# ===========================================
## 地牢生成过程中可能遇到的错误类型
## 使用枚举便于错误处理和调试
enum DungeonError {
	## 生成成功
	SUCCESS = 0,
	## 配置参数无效
	INVALID_CONFIG = 1,
	## 生成过程失败
	GENERATION_FAILED = 2,
	## 无法生成任何房间
	NO_ROOMS_GENERATED = 3,
	## 无法建立房间连接
	NO_CONNECTIONS_POSSIBLE = 4,
	## 坐标超出有效范围
	INVALID_COORDINATES = 5,
	## 网格访问越界
	GRID_OUT_OF_BOUNDS = 6,
	## 房间重叠
	ROOM_OVERLAP = 7,
	## BSP树分割失败
	BSP_SPLIT_FAILED = 8,
}

# ===========================================
# 地牢元素类型
# ===========================================
## 地牢网格中不同类型单元格的枚举定义
## 每种类型都有特定的含义和渲染方式
enum CellType {
	## 空白区域，未使用的空间
	EMPTY = 0,
	## 房间地面，可行走区域
	ROOM_FLOOR = 1,
	## 墙壁，不可通过的障碍物
	WALL = 2,
	## 走廊，连接房间的通道
	CORRIDOR = 3,
	## 门，房间与走廊的连接点
	DOOR = 4,
}

# ===========================================
# 基础数据结构 - 使用内部类组织
# ===========================================

# ===========================================
# 2D坐标点
# ===========================================
## 表示2D空间中的坐标点，用于地牢中的位置计算
## 提供距离计算和序列化功能
class Point:
	## X坐标
	var x: int
	## Y坐标
	var y: int
	
	## 构造函数
	## @param p_x: X坐标
	## @param p_y: Y坐标
	func _init(p_x: int, p_y: int):
		x = p_x
		y = p_y
	
	## 计算到另一个点的欧几里得距离
	## @param other: 目标点
	## @return: 两点之间的直线距离
	func distance_to(other: Point) -> float:
		var dx = x - other.x
		var dy = y - other.y
		return sqrt(dx * dx + dy * dy)
	
	## 转换为字典格式，便于序列化和调试
	## @return: 包含x,y坐标的字典
	func to_dict() -> Dictionary:
		return {"x": x, "y": y}


# ===========================================
# 房间数据结构
# ===========================================
## 表示地牢中的矩形房间，包含位置、尺寸和计算方法
## 房间是地牢的基本组成单元，通过走廊相互连接
class Room:
	## 房间左上角X坐标
	var x: int
	## 房间左上角Y坐标
	var y: int
	## 房间宽度
	var width: int
	## 房间高度
	var height: int
	
	## 构造函数
	## @param p_x: 左上角X坐标
	## @param p_y: 左上角Y坐标
	## @param p_width: 房间宽度
	## @param p_height: 房间高度
	func _init(p_x: int, p_y: int, p_width: int, p_height: int):
		x = p_x
		y = p_y
		width = p_width
		height = p_height
	
	func get_center() -> Point:
		return Point.new(x + width / 2, y + height / 2)
	
	func get_bounds() -> Array:
		return [x, y, x + width - 1, y + height - 1]
	
	func contains_point(point: Point) -> bool:
		return (x <= point.x and point.x < x + width and 
				y <= point.y and point.y < y + height)
	
	func distance_to(other: Room) -> float:
		return get_center().distance_to(other.get_center())
	
	func to_dict() -> Dictionary:
		return {
			"x": x, "y": y, 
			"width": width, "height": height,
			"center_x": get_center().x,
			"center_y": get_center().y
		}

# BSP树节点
class BSPNode:
	var x: int
	var y: int
	var width: int
	var height: int
	var level: int
	var left_child: BSPNode
	var right_child: BSPNode
	var room: Room
	var split_direction: String  # "horizontal" or "vertical"
	var split_position: int
	
	func _init(p_x: int, p_y: int, p_width: int, p_height: int, p_level: int):
		x = p_x
		y = p_y
		width = p_width
		height = p_height
		level = p_level
		left_child = null
		right_child = null
		room = null
		split_direction = ""
		split_position = 0

# 房间连接信息
class Connection:
	var room1: Room
	var room2: Room
	var corridor: Array[Point]
	var distance: float
	var connection_type: String  # "mst" or "extra"
	
	func _init(p_room1: Room, p_room2: Room, p_corridor: Array[Point], 
			   p_distance: float, p_type: String):
		room1 = p_room1
		room2 = p_room2
		corridor = p_corridor
		distance = p_distance
		connection_type = p_type
	
	func to_dict() -> Dictionary:
		return {
			"room1": room1.to_dict(),
			"room2": room2.to_dict(),
			"corridor": corridor.map(func(p): return p.to_dict()),
			"distance": distance,
			"type": connection_type
		}

# 门信息
class Door:
	var x: int
	var y: int
	var adjacent_rooms: Array[Room]
	var room_count: int
	
	func _init(p_x: int, p_y: int, p_rooms: Array[Room]):
		x = p_x
		y = p_y
		adjacent_rooms = p_rooms
		room_count = p_rooms.size()
	
	func to_dict() -> Dictionary:
		return {
			"x": x, "y": y,
			"adjacent_rooms": adjacent_rooms.map(func(r): return r.to_dict()),
			"room_count": room_count
		}

# ===========================================
# 配置类
# ===========================================
class DungeonConfig:
	var width: int = 128
	var height: int = 128
	var min_room_size: int = 8
	var max_room_size: int = 20
	var min_room_distance: int = 5
	var min_split_size: int = 20
	var split_ratio: float = 1.25
	var split_probability: float = 0.75
	var room_size_ratio_min: float = 0.4
	var room_size_ratio_max: float = 0.8
	var extra_connection_ratio: float = 0.3
	var extra_connection_probability: float = 0.5
	var cycle_connection_attempts: int = 10
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		# 基础尺寸验证
		if width < 50 or height < 50:
			errors.append("地图尺寸太小，最小为50x50")
		if width > 2048 or height > 2048:
			errors.append("地图尺寸太大，最大为2048x2048")
		
		# 房间参数验证
		if min_room_size < 4:
			errors.append("房间最小尺寸太小，至少为4x4")
		if max_room_size > 50:
			errors.append("房间最大尺寸太大，最大为50x50")
		if min_room_size > max_room_size:
			errors.append("房间最小尺寸不能大于最大尺寸")
		
		# 其他验证...
		
		return errors
	
	func clone() -> DungeonConfig:
		var config = DungeonConfig.new()
		config.width = width
		config.height = height
		config.min_room_size = min_room_size
		config.max_room_size = max_room_size
		config.min_room_distance = min_room_distance
		config.min_split_size = min_split_size
		config.split_ratio = split_ratio
		config.split_probability = split_probability
		config.room_size_ratio_min = room_size_ratio_min
		config.room_size_ratio_max = room_size_ratio_max
		config.extra_connection_ratio = extra_connection_ratio
		config.extra_connection_probability = extra_connection_probability
		config.cycle_connection_attempts = cycle_connection_attempts
		return config
	
	func update(options: Dictionary) -> Array[String]:
		if options.has("width"): width = options["width"]
		if options.has("height"): height = options["height"]
		if options.has("min_room_size"): min_room_size = options["min_room_size"]
		if options.has("max_room_size"): max_room_size = options["max_room_size"]
		if options.has("min_room_distance"): min_room_distance = options["min_room_distance"]
		if options.has("min_split_size"): min_split_size = options["min_split_size"]
		if options.has("split_ratio"): split_ratio = options["split_ratio"]
		if options.has("split_probability"): split_probability = options["split_probability"]
		if options.has("room_size_ratio_min"): room_size_ratio_min = options["room_size_ratio_min"]
		if options.has("room_size_ratio_max"): room_size_ratio_max = options["room_size_ratio_max"]
		if options.has("extra_connection_ratio"): extra_connection_ratio = options["extra_connection_ratio"]
		if options.has("extra_connection_probability"): extra_connection_probability = options["extra_connection_probability"]
		if options.has("cycle_connection_attempts"): cycle_connection_attempts = options["cycle_connection_attempts"]
		
		return validate()

# ===========================================
# 数学工具类 - 使用static方法
# ===========================================
class MathUtils:
	static func random_int(min_val: int, max_val: int) -> int:
		return randi() % (max_val - min_val + 1) + min_val
	
	static func random_float(min_val: float, max_val: float) -> float:
		return randf() * (max_val - min_val) + min_val
	
	static func clamp(value: float, min_val: float, max_val: float) -> float:
		return max(min_val, min(value, max_val))
	
	static func distance(p1: Point, p2: Point) -> float:
		return p1.distance_to(p2)
	
	static func manhattan_distance(p1: Point, p2: Point) -> int:
		return abs(p1.x - p2.x) + abs(p1.y - p2.y)

# ===========================================
# 主生成器类
# ===========================================
var config: DungeonConfig
var grid: Array
var rooms: Array[Room]
var connections: Array[Connection]
var doors: Array[Door]

# 生成统计
var generation_stats: Dictionary = {
	"last_generation_time": 0.0,
	"total_generations": 0
}

func _init(p_config: DungeonConfig = null):
	config = p_config if p_config else DungeonConfig.new()
	
	# 验证配置
	var errors = config.validate()
	if not errors.is_empty():
		push_error("配置无效: " + ", ".join(errors))
	
	# 初始化状态
	grid = []
	rooms = []
	connections = []
	doors = []

## 生成完整地牢，返回包含网格、房间、连接等信息的字典
func generate() -> Dictionary:
	var start_time = Time.get_ticks_msec()
	
	# 1. 初始化网格
	if not _init_grid():
		return _create_error_result(DungeonError.GENERATION_FAILED, "网格初始化失败")
	
	# 2. 生成BSP树
	var leaves = _create_bsp_tree()
	if leaves.is_empty():
		return _create_error_result(DungeonError.BSP_SPLIT_FAILED, "无法生成BSP树叶节点")
	
	# 3. 生成房间
	var room_result = _generate_rooms_in_leaves(leaves)
	if room_result.is_empty():
		return _create_error_result(DungeonError.NO_ROOMS_GENERATED, "无法生成任何房间")
	
	# 4. 在网格中放置房间
	_place_rooms_on_grid()
	
	# 5. 连接房间
	if not _connect_rooms():
		return _create_error_result(DungeonError.NO_CONNECTIONS_POSSIBLE, "无法连接房间")
	
	# 6. 放置门
	_place_doors()
	
	# 7. 裁剪孤立门
	_trim_isolated_doors()
	
	# 8. 添加墙壁
	_add_walls()
	
	# 更新统计
	var end_time = Time.get_ticks_msec()
	generation_stats["last_generation_time"] = end_time - start_time
	generation_stats["total_generations"] += 1
	
	return _create_success_result(get_result())

## 初始化地牢网格
func _init_grid() -> bool:
	grid.clear()
	for y in range(config.height):
		var row: Array[int] = []
		for x in range(config.width):
			row.append(CellType.EMPTY)
		grid.append(row)
	return true

## 创建BSP树，返回所有叶节点
func _create_bsp_tree() -> Array[BSPNode]:
	var root = BSPNode.new(0, 0, config.width, config.height, 0)
	var leaves: Array[BSPNode] = []
	
	_split_bsp_node(root, leaves)
	
	return leaves

func _split_bsp_node(node: BSPNode, leaves: Array[BSPNode]) -> void:
## 递归分割BSP节点
	# 检查是否需要继续分割
	if (node.width < config.min_split_size * 2 or 
		node.height < config.min_split_size * 2):
		leaves.append(node)
		return
	
	# 根据概率决定是否分割
	if randf() > config.split_probability:
		leaves.append(node)
		return
	
	# 决定分割方向
	var split_direction: String
	if node.width / node.height > config.split_ratio:
		split_direction = "vertical"
	elif node.height / node.width > config.split_ratio:
		split_direction = "horizontal"
	else:
		if randf() < 0.5:
			split_direction = "vertical"
		else:
			split_direction = "horizontal"
	
	# 计算分割位置
	var split_position: int
	if split_direction == "vertical":
		var min_pos = node.x + config.min_split_size
		var max_pos = node.x + node.width - config.min_split_size
		if min_pos >= max_pos:
			leaves.append(node)
			return
		split_position = MathUtils.random_int(min_pos, max_pos)
	else:
		var min_pos = node.y + config.min_split_size
		var max_pos = node.y + node.height - config.min_split_size
		if min_pos >= max_pos:
			leaves.append(node)
			return
		split_position = MathUtils.random_int(min_pos, max_pos)
	
	# 创建子节点
	var left_child: BSPNode
	var right_child: BSPNode
	
	if split_direction == "vertical":
		left_child = BSPNode.new(
			node.x, node.y,
			split_position - node.x, node.height,
			node.level + 1
		)
		right_child = BSPNode.new(
			split_position, node.y,
			node.x + node.width - split_position, node.height,
			node.level + 1
		)
	else:
		left_child = BSPNode.new(
			node.x, node.y,
			node.width, split_position - node.y,
			node.level + 1
		)
		right_child = BSPNode.new(
			node.x, split_position,
			node.width, node.y + node.height - split_position,
			node.level + 1
		)
	
	# 设置节点属性
	node.split_direction = split_direction
	node.split_position = split_position
	node.left_child = left_child
	node.right_child = right_child
	
	# 递归分割子节点
	_split_bsp_node(left_child, leaves)
	_split_bsp_node(right_child, leaves)

func _generate_rooms_in_leaves(leaves: Array[BSPNode]) -> Array[Room]:
## 在BSP叶节点中生成房间
	rooms.clear()
	
	for leaf in leaves:
		var room = _generate_room_in_leaf(leaf)
		if room:
			rooms.append(room)
	
	return rooms

func _generate_room_in_leaf(leaf: BSPNode) -> Room:
## 在单个叶节点中生成房间
	# 计算房间大小范围
	var max_width = min(leaf.width - 2, config.max_room_size)
	var max_height = min(leaf.height - 2, config.max_room_size)
	
	if max_width < config.min_room_size or max_height < config.min_room_size:
		return null
	
	# 随机决定房间大小
	var room_width = MathUtils.random_int(config.min_room_size, max_width)
	var room_height = MathUtils.random_int(config.min_room_size, max_height)
	
	# 确保房间占据足够的空间
	var min_ratio = config.room_size_ratio_min
	var max_ratio = config.room_size_ratio_max
	
	var width_ratio = room_width / leaf.width
	var height_ratio = room_height / leaf.height
	
	if width_ratio < min_ratio:
		room_width = leaf.width * min_ratio
	elif width_ratio > max_ratio:
		room_width = leaf.width * max_ratio
	
	if height_ratio < min_ratio:
		room_height = leaf.height * min_ratio
	elif height_ratio > max_ratio:
		room_height = leaf.height * max_ratio
	
	# 计算房间位置
	var max_x = leaf.x + leaf.width - room_width - 1
	var max_y = leaf.y + leaf.height - room_height - 1
	
	if max_x < leaf.x or max_y < leaf.y:
		return null
	
	var room_x = MathUtils.random_int(leaf.x + 1, max_x)
	var room_y = MathUtils.random_int(leaf.y + 1, max_y)
	
	# 创建房间
	var room = Room.new(room_x, room_y, room_width, room_height)
	
	# 检查与其他房间的距离
	for existing_room in rooms:
		var distance = _calculate_room_distance(room, existing_room)
		if distance < config.min_room_distance:
			return null
	
	return room

func _calculate_room_distance(room1: Room, room2: Room) -> int:
## 计算两个房间之间的最小距离（墙壁到墙壁）
	# 计算水平和垂直方向的距离
	var x_distance = max(0, max(room1.x - (room2.x + room2.width), 
								room2.x - (room1.x + room1.width)))
	var y_distance = max(0, max(room1.y - (room2.y + room2.height), 
								room2.y - (room1.y + room1.height)))
	
	# 返回欧几里得距离
	return sqrt(x_distance * x_distance + y_distance * y_distance)

func _place_rooms_on_grid() -> void:
## 在网格中放置房间
	for room in rooms:
		for y in range(room.y, room.y + room.height):
			for x in range(room.x, room.x + room.width):
				if (0 <= x and x < config.width and 
					0 <= y and y < config.height):
					grid[y][x] = CellType.ROOM_FLOOR

func _connect_rooms() -> bool:
## 连接所有房间
	if rooms.size() < 2:
		return true
	
	# 生成所有可能的连接
	var possible_connections: Array[Array] = []
	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			var distance = rooms[i].distance_to(rooms[j])
			possible_connections.append([i, j, distance])
	
	# 按距离排序
	possible_connections.sort_custom(func(a, b): return a[2] < b[2])
	
	# 使用并查集构建最小生成树
	var parent: Array[int] = []
	for i in range(rooms.size()):
		parent.append(i)
	
	var find_func = func(x: int) -> int:
		while parent[x] != x:
			parent[x] = parent[parent[x]]
			x = parent[x]
		return x
	
	var union_func = func(x: int, y: int) -> void:
		var px = find_func.call(x)
		var py = find_func.call(y)
		if px != py:
			parent[px] = py
	
	# 构建MST
	var mst_connections: Array[Connection] = []
	for conn in possible_connections:
		var i = conn[0]
		var j = conn[1]
		var distance = conn[2]
		
		if find_func.call(i) != find_func.call(j):
			union_func.call(i, j)
			
			# 生成走廊
			var corridor = _generate_corridor(rooms[i], rooms[j])
			if corridor:
				var connection = Connection.new(rooms[i], rooms[j], corridor, distance, "mst")
				mst_connections.append(connection)
				
				# 在网格中放置走廊
				_place_corridor_on_grid(corridor)
	
	# 添加额外连接创建环路
	var extra_count = int(mst_connections.size() * config.extra_connection_ratio)
	var extra_connections: Array[Connection] = []
	
	for attempt in range(config.cycle_connection_attempts):
		if extra_connections.size() >= extra_count:
			break
		
		if possible_connections.is_empty():
			break
		
		# 随机选择一个连接
		var idx = MathUtils.random_int(0, possible_connections.size() - 1)
		var conn = possible_connections[idx]
		possible_connections.remove_at(idx)
		
		var i = conn[0]
		var j = conn[1]
		var distance = conn[2]
		
		# 检查是否已经连接
		if find_func.call(i) != find_func.call(j):
			continue
		
		# 按概率决定是否添加
		if randf() < config.extra_connection_probability:
			var corridor = _generate_corridor(rooms[i], rooms[j])
			if corridor:
				var connection = Connection.new(rooms[i], rooms[j], corridor, distance, "extra")
				extra_connections.append(connection)
				
				# 在网格中放置走廊
				_place_corridor_on_grid(corridor)
	
	connections = mst_connections + extra_connections
	return true

func _generate_corridor(room1: Room, room2: Room) -> Array[Point]:
## 生成连接两个房间的走廊
	var start = room1.get_center()
	var end = room2.get_center()
	var corridor: Array[Point] = []
	
	# 随机选择走廊生成策略
	if randf() < 0.5:
		# 先水平后垂直
		corridor = _generate_l_shaped_corridor(start, end, true)
	else:
		# 先垂直后水平
		corridor = _generate_l_shaped_corridor(start, end, false)
	
	return corridor

func _generate_l_shaped_corridor(start: Point, end: Point, horizontal_first: bool) -> Array[Point]:
## 生成L型走廊
	var corridor: Array[Point] = []
	
	if horizontal_first:
		# 先水平移动
		var current_x = start.x
		var current_y = start.y
		
		# 水平移动到中间点
		while current_x != end.x:
			corridor.append(Point.new(current_x, current_y))
			if current_x < end.x:
				current_x += 1
			else:
				current_x -= 1
		
		# 垂直移动到终点
		while current_y != end.y:
			corridor.append(Point.new(current_x, current_y))
			if current_y < end.y:
				current_y += 1
			else:
				current_y -= 1
	else:
		# 先垂直移动
		var current_x = start.x
		var current_y = start.y
		
		# 垂直移动到中间点
		while current_y != end.y:
			corridor.append(Point.new(current_x, current_y))
			if current_y < end.y:
				current_y += 1
			else:
				current_y -= 1
		
		# 水平移动到终点
		while current_x != end.x:
			corridor.append(Point.new(current_x, current_y))
			if current_x < end.x:
				current_x += 1
			else:
				current_x -= 1
	
	# 添加终点
	corridor.append(Point.new(end.x, end.y))
	
	return corridor

func _place_corridor_on_grid(corridor: Array[Point]) -> void:
## 在网格中放置走廊
	for point in corridor:
		if (0 <= point.x and point.x < config.width and 
			0 <= point.y and point.y < config.height):
			if grid[point.y][point.x] == CellType.EMPTY:
				grid[point.y][point.x] = CellType.CORRIDOR

func _place_doors() -> void:
## 放置门
	doors.clear()
	
	# 遍历所有走廊格子
	for y in range(config.height):
		for x in range(config.width):
			if grid[y][x] == CellType.CORRIDOR:
				# 检查是否与房间相邻
				var adjacent_rooms = _get_adjacent_rooms(x, y)
				if not adjacent_rooms.is_empty():
					# 将走廊格子转换为门
					grid[y][x] = CellType.DOOR
					var door = Door.new(x, y, adjacent_rooms)
					doors.append(door)

func _get_adjacent_rooms(x: int, y: int) -> Array[Room]:
## 获取指定位置相邻的房间
	var adjacent_rooms: Array[Room] = []
	
	# 检查四个方向
	for dir in [[0, 1], [0, -1], [1, 0], [-1, 0]]:
		var nx = x + dir[0]
		var ny = y + dir[1]
		if (0 <= nx and nx < config.width and 
			0 <= ny and ny < config.height):
			if grid[ny][nx] == CellType.ROOM_FLOOR:
				# 找到包含这个格子的房间
				for room in rooms:
					if room.contains_point(Point.new(nx, ny)):
						if not adjacent_rooms.has(room):
							adjacent_rooms.append(room)
						break
	
	return adjacent_rooms

func _trim_isolated_doors() -> void:
## 裁剪孤立的门
	var doors_to_remove: Array[Door] = []
	
	for door in doors:
		# 检查门是否与走廊相连
		var has_corridor = false
		for dir in [[0, 1], [0, -1], [1, 0], [-1, 0]]:
			var nx = door.x + dir[0]
			var ny = door.y + dir[1]
			if (0 <= nx and nx < config.width and 
				0 <= ny and ny < config.height):
				if grid[ny][nx] == CellType.CORRIDOR:
					has_corridor = true
					break
		
		if not has_corridor:
			doors_to_remove.append(door)
	
	# 移除孤立门
	for door in doors_to_remove:
		doors.erase(door)
		grid[door.y][door.x] = CellType.EMPTY

func _add_walls() -> void:
## 添加墙壁
	# 使用3x3核算法
	var new_grid = grid.duplicate(true)
	
	for y in range(config.height):
		for x in range(config.width):
			if grid[y][x] != CellType.EMPTY:
				# 检查周围的空白格子
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var nx = x + dx
						var ny = y + dy
						if (0 <= nx and nx < config.width and 
							0 <= ny and ny < config.height):
							if grid[ny][nx] == CellType.EMPTY:
								new_grid[ny][nx] = CellType.WALL
	
	grid = new_grid

func get_result() -> Dictionary:
## 获取生成结果
	# 计算统计信息
	var cell_counts = _calculate_cell_counts()
	var stats = _calculate_stats(cell_counts)
	
	return {
		"grid": grid,
		"rooms": rooms.map(func(r): return r.to_dict()),
		"connections": connections.map(func(c): return c.to_dict()),
		"doors": doors.map(func(d): return d.to_dict()),
		"config": _config_to_dict(),
		"stats": stats
	}

func _calculate_cell_counts() -> Dictionary:
## 计算各种单元格的数量
	var counts = {
		"empty": 0,
		"room_floor": 0,
		"wall": 0,
		"corridor": 0,
		"door": 0
	}
	
	for row in grid:
		for cell in row:
			match cell:
				CellType.EMPTY:
					counts["empty"] += 1
				CellType.ROOM_FLOOR:
					counts["room_floor"] += 1
				CellType.WALL:
					counts["wall"] += 1
				CellType.CORRIDOR:
					counts["corridor"] += 1
				CellType.DOOR:
					counts["door"] += 1
	
	return counts

func _calculate_stats(cell_counts: Dictionary) -> Dictionary:
## 计算统计信息
	var total_cells = config.width * config.height
	var used_cells = total_cells - cell_counts["empty"]
	
	# 房间统计
	var room_sizes = []
	for room in rooms:
		room_sizes.append({
			"width": room.width,
			"height": room.height,
			"area": room.width * room.height
		})
	var avg_room_size = 0.0
	if not room_sizes.is_empty():
		var total_area = 0
		for size in room_sizes:
			total_area += size["area"]
		avg_room_size = total_area / room_sizes.size()
	
	# 连接统计
	var mst_count = 0
	for conn in connections:
		if conn.connection_type == "mst":
			mst_count += 1
	var extra_count = connections.size() - mst_count
	var total_length = 0
	for conn in connections:
		total_length += conn.corridor.size()
	var avg_length = 0.0
	if not connections.is_empty():
		avg_length = total_length / connections.size()
	
	# 门统计
	var single_room_doors = 0
	var multi_room_doors = 0
	for door in doors:
		if door.room_count == 1:
			single_room_doors += 1
		else:
			multi_room_doors += 1
	
	# 先创建字典
	var stats = {
		"room_count": rooms.size(),
		"connection_count": connections.size(),
		"door_count": doors.size(),
		"cell_counts": cell_counts,
		"total_cells": total_cells,
		"used_cells": used_cells,
		"coverage_ratio": used_cells / total_cells,
		"wall_ratio": cell_counts["wall"] / total_cells,
		"room_sizes": room_sizes,
		"average_room_size": avg_room_size,
		"last_generation_time": generation_stats["last_generation_time"],
		"total_generations": generation_stats["total_generations"],
		"room_generator_stats": {
			"generated": rooms.size(),
			"failed": 0,  # TODO: 实现失败统计
			"success_rate": 1.0
		},
		"connection_stats": {
			"total": connections.size(),
			"mst": mst_count,
			"extra": extra_count,
			"total_length": total_length,
			"average_length": avg_length
		},
		"door_stats": {
			"total": doors.size(),
			"single_room": single_room_doors,
			"multi_room": multi_room_doors,
			"positions": doors.map(func(d): return {"x": d.x, "y": d.y})
		},
		"wall_stats": {
			"wall_count": cell_counts["wall"],
			"coverage": cell_counts["wall"] / total_cells
		}
	}
	
	# 计算环路比率
	if not connections.is_empty():
		stats["cycle_ratio"] = extra_count / connections.size()
	else:
		stats["cycle_ratio"] = 0.0
	
	return stats

func _config_to_dict() -> Dictionary:
## 配置转字典
	return {
		"width": config.width,
		"height": config.height,
		"min_room_size": config.min_room_size,
		"max_room_size": config.max_room_size,
		"min_room_distance": config.min_room_distance,
		"min_split_size": config.min_split_size,
		"split_ratio": config.split_ratio,
		"split_probability": config.split_probability,
		"room_size_ratio_min": config.room_size_ratio_min,
		"room_size_ratio_max": config.room_size_ratio_max,
		"extra_connection_ratio": config.extra_connection_ratio,
		"extra_connection_probability": config.extra_connection_probability,
		"cycle_connection_attempts": config.cycle_connection_attempts
	}

func clear() -> Dictionary:
## 清空地牢
	_init_grid()
	rooms.clear()
	connections.clear()
	doors.clear()
	return get_result()

func update_config(options: Dictionary) -> Array[String]:
## 更新配置
	return config.update(options)

# ===========================================
# 辅助函数
# ===========================================
func _create_success_result(value) -> Dictionary:
	return {
		"success": true,
		"value": value,
		"error": DungeonError.SUCCESS,
		"message": ""
	}

func _create_error_result(error_code: int, message: String) -> Dictionary:
	return {
		"success": false,
		"value": null,
		"error": error_code,
		"message": message
	}

# ===========================================
# 静态工厂方法
# ===========================================
## 创建测试用生成器，使用默认配置
static func create_test_generator(width: int = 64, height: int = 64) -> DungeonGenerator:
	# 确保最小尺寸
	width = max(width, 50)
	height = max(height, 50)
	
	# 调整房间大小以适应小地图
	var max_room_size = min(20, min(width, height) / 4)
	
	var config = DungeonConfig.new()
	config.width = width
	config.height = height
	config.min_room_size = 6
	config.max_room_size = max_room_size
	config.min_room_distance = 3
	
	return DungeonGenerator.new(config)

# ===========================================
# 工具函数
# ===========================================
static func print_grid_ascii(grid: Array, config: DungeonConfig) -> void:
## 打印ASCII形式的地牢
	var symbols = {
		CellType.EMPTY: " ",
		CellType.ROOM_FLOOR: ".",
		CellType.WALL: "#",
		CellType.CORRIDOR: "+",
		CellType.DOOR: "D"
	}
	
	for row in grid:
		var line = ""
		for cell in row:
			line += symbols.get(cell, "?")
		print(line)
