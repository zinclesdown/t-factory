# DungeonGeneratorAPI.gd
# 地牢生成器API接口
#
# 这是一个简化的API接口，提供单一方法来生成地牢
# 封装了复杂的DungeonGenerator类，提供简单的参数化接口
# 
# 主要特性：
# - 单一方法调用生成完整地牢
# - 支持所有地牢生成参数配置
# - 返回标准的2D枚举数组
# - 提供合理的默认值
# 
# @author Claude Code
# @version 2.1
# @date 2025-09-01

@tool
extends RefCounted
class_name DungeonGeneratorAPI

# ===========================================
# 地牢元素类型枚举（重新暴露）
# ===========================================
## 地牢网格中不同类型单元格的枚举定义
## 与DungeonGenerator.CellType保持一致
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
# 主要API方法
# ===========================================

## 生成地牢的主要API方法
## 
## 该方法封装了完整的地牢生成流程，提供简化的接口
## 
## @param width: 地牢宽度（默认128）
## @param height: 地牢高度（默认128）
## @param min_room_size: 房间最小尺寸（默认8）
## @param max_room_size: 房间最大尺寸（默认20）
## @param min_room_distance: 房间间最小距离（默认5）
## @param min_split_size: BSP分割最小尺寸（默认20）
## @param split_ratio: 强制分割的长宽比阈值（默认1.25）
## @param split_probability: BSP分割概率（默认0.75）
## @param room_size_ratio_min: 房间占叶节点的最小比例（默认0.4）
## @param room_size_ratio_max: 房间占叶节点的最大比例（默认0.8）
## @param extra_connection_ratio: 额外连接数量比例（默认0.3）
## @param extra_connection_probability: 额外连接概率（默认0.5）
## @param cycle_connection_attempts: 尝试创建环路连接的次数（默认10）
## 
## @return: 二维数组，表示生成的地牢网格，每个元素为CellType枚举值
## @return: 如果生成失败，返回空数组并输出错误信息
func generate_dungeon(
	width: int = 128,
	height: int = 128,
	min_room_size: int = 8,
	max_room_size: int = 20,
	min_room_distance: int = 5,
	min_split_size: int = 20,
	split_ratio: float = 1.25,
	split_probability: float = 0.75,
	room_size_ratio_min: float = 0.4,
	room_size_ratio_max: float = 0.8,
	extra_connection_ratio: float = 0.3,
	extra_connection_probability: float = 0.5,
	cycle_connection_attempts: int = 10
) -> Array[Array]:
	
	# 创建配置对象
	var config = DungeonGenerator.DungeonConfig.new()
	
	# 设置配置参数
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
	
	# 验证配置
	var validation_errors = config.validate()
	if not validation_errors.is_empty():
		push_error("地牢配置验证失败: " + ", ".join(validation_errors))
		var empty_grid: Array[Array] = []
		return empty_grid
	
	# 创建生成器
	var generator = DungeonGenerator.new(config)
	
	# 生成地牢
	var result = generator.generate()
	
	# 检查生成结果
	if not result["success"]:
		push_error("地牢生成失败: " + result["message"])
		var empty_grid: Array[Array] = []
		return empty_grid
	
	# 获取网格数据并进行类型转换
	var grid_data = result["value"]["grid"]
	var typed_grid: Array[Array] = []
	typed_grid.append_array(grid_data)
	
	# 返回类型化的网格数据
	return typed_grid

# ===========================================
# 便捷方法
# ===========================================

## 生成小型地牢（适合测试和快速原型）
## 
## @param size: 地牢尺寸（默认64）
## @return: 小型地牢的2D网格数组
func generate_small_dungeon(size: int = 64) -> Array[Array]:
	return generate_dungeon(
		size, size,                    # width, height
		6, 12,                         # min_room_size, max_room_size
		3,                             # min_room_distance
		16,                            # min_split_size
		1.3,                           # split_ratio
		0.8,                           # split_probability
		0.3, 0.7,                      # room_size_ratio_min, room_size_ratio_max
		0.2, 0.4,                      # extra_connection_ratio, extra_connection_probability
		5                              # cycle_connection_attempts
	)

## 生成大型地牢（适合完整游戏）
## 
## @param size: 地牢尺寸（默认256）
## @return: 大型地牢的2D网格数组
func generate_large_dungeon(size: int = 256) -> Array[Array]:
	return generate_dungeon(
		size, size,                    # width, height
		12, 25,                        # min_room_size, max_room_size
		8,                             # min_room_distance
		32,                            # min_split_size
		1.25,                          # split_ratio
		0.75,                          # split_probability
		0.5, 0.8,                      # room_size_ratio_min, room_size_ratio_max
		0.3, 0.6,                      # extra_connection_ratio, extra_connection_probability
		15                             # cycle_connection_attempts
	)

## 生成密集型地牢（更多房间和连接）
## 
## @return: 密集型地牢的2D网格数组
func generate_dense_dungeon() -> Array[Array]:
	return generate_dungeon(
		128, 128,                      # width, height
		6, 15,                         # min_room_size, max_room_size
		2,                             # min_room_distance
		16,                            # min_split_size
		1.5,                           # split_ratio
		0.9,                           # split_probability
		0.6, 0.9,                      # room_size_ratio_min, room_size_ratio_max
		0.5, 0.7,                      # extra_connection_ratio, extra_connection_probability
		20                             # cycle_connection_attempts
	)

## 生成稀疏型地牢（更少房间，更大空间）
## 
## @return: 稀疏型地牢的2D网格数组
func generate_sparse_dungeon() -> Array[Array]:
	return generate_dungeon(
		128, 128,                      # width, height
		10, 20,                        # min_room_size, max_room_size
		8,                             # min_room_distance
		24,                            # min_split_size
		1.2,                           # split_ratio
		0.6,                           # split_probability
		0.3, 0.6,                      # room_size_ratio_min, room_size_ratio_max
		0.1, 0.3,                      # extra_connection_ratio, extra_connection_probability
		5                              # cycle_connection_attempts
	)

# ===========================================
# 工具方法
# ===========================================

## 将地牢网格转换为ASCII字符串表示
## 
## @param grid: 地牢网格数组
## @return: ASCII字符串表示
func grid_to_ascii(grid: Array) -> String:
	if grid.is_empty():
		return ""
	
	var symbols = {
		CellType.EMPTY: " ",
		CellType.ROOM_FLOOR: ".",
		CellType.WALL: "#",
		CellType.CORRIDOR: "+",
		CellType.DOOR: "D"
	}
	
	var ascii_text = ""
	for row in grid:
		for cell in row:
			ascii_text += symbols.get(cell, "?")
		ascii_text += "\n"
	
	return ascii_text

## 打印地牢网格到控制台
## 
## @param grid: 地牢网格数组
func print_grid(grid: Array) -> void:
	print(grid_to_ascii(grid))

## 获取地牢统计信息
## 
## @param grid: 地牢网格数组
## @return: 包含统计信息的字典
func get_grid_stats(grid: Array) -> Dictionary:
	if grid.is_empty():
		return {}
	
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
	
	var total_cells = grid.size() * grid[0].size()
	var used_cells = total_cells - counts["empty"]
	
	return {
		"total_cells": total_cells,
		"used_cells": used_cells,
		"coverage_ratio": float(used_cells) / total_cells,
		"cell_counts": counts,
		"room_count": counts["room_floor"] / 20.0,  # 估算房间数量
		"door_count": counts["door"],
		"corridor_length": counts["corridor"]
	}

# ===========================================
# 使用示例
# ===========================================

## 基本使用示例
func _example_basic_usage():
	# 生成默认大小的地牢
	var dungeon = generate_dungeon()
	
	# 访问特定位置的单元格
	var cell_type = dungeon[10][15]
	
	# 检查单元格类型
	if cell_type == CellType.ROOM_FLOOR:
		print("这是房间地面")
	elif cell_type == CellType.WALL:
		print("这是墙壁")

## 自定义参数示例
func _example_custom_params():
	# 生成自定义参数的地牢
	var custom_dungeon = generate_dungeon(
		200, 200,          # 200x200的地牢
		10, 25,            # 房间大小范围
		6,                 # 房间间距
		25,                # BSP最小分割
		1.3, 0.8,          # 分割参数
		0.4, 0.75,         # 房间比例
		0.4, 0.6, 12       # 连接参数
	)
	
	# 获取统计信息
	var stats = get_grid_stats(custom_dungeon)
	print("地牢覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))

## 便捷方法示例
func _example_preset_methods():
	# 生成不同类型的地牢
	var small_dungeon = generate_small_dungeon(64)
	var large_dungeon = generate_large_dungeon(256)
	var dense_dungeon = generate_dense_dungeon()
	
	# 打印小型地牢
	print("小型地牢:")
	print_grid(small_dungeon)

# ===========================================
# 静态工厂方法
# ===========================================

## 创建API实例并返回
## 
## @return: DungeonGeneratorAPI实例
static func create() -> DungeonGeneratorAPI:
	return DungeonGeneratorAPI.new()

## 快速生成地牢的静态方法
## 
## @param width: 地牢宽度
## @param height: 地牢高度
## @return: 地牢网格数组
static func quick_generate(width: int = 128, height: int = 128) -> Array[Array]:
	var api = DungeonGeneratorAPI.new()
	return api.generate_dungeon(width, height)
