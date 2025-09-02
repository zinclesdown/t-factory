# DungeonTestAPI.gd
# 使用EditorScript在编辑器中测试DungeonGeneratorAPI
#
# 这个测试脚本专门测试新的简化API接口
# 验证各种参数配置和错误处理场景
#
# @author Claude Code
# @version 2.1
# @date 2025-09-01

@tool
extends EditorScript

## 在编辑器中运行API测试
func _run():
	print("=== DungeonGenerator API 测试 ===")
	
	# 测试0: 类型系统特性
	print("\n0. 测试类型系统特性...")
	test_type_system()
	
	# 测试1: 基本API调用
	print("\n1. 测试基本API调用...")
	test_basic_api()
	
	# 测试2: 参数化生成
	print("\n2. 测试参数化生成...")
	test_parameterized_generation()
	
	# 测试3: 便捷方法
	print("\n3. 测试便捷方法...")
	test_convenience_methods()
	
	# 测试4: 错误处理
	print("\n4. 测试错误处理...")
	test_error_handling()
	
	# 测试5: 工具方法
	print("\n5. 测试工具方法...")
	test_utility_methods()
	
	# 测试6: 性能测试
	print("\n6. 性能测试...")
	test_performance()
	
	print("\n=== API 测试完成 ===")

## 测试类型系统特性
func test_type_system():
	print("\n0. 测试类型系统特性...")
	
	# 测试类型化数组转换（按照你的提示）
	print("   测试类型化数组转换...")
	
	var untyped_array: Array = []
	var typed_array: Array[Array] = []
	
	# 填充一些测试数据
	untyped_array.append([1, 2, 3])
	untyped_array.append([4, 5, 6])
	
	# 错误示范（注释掉，避免报错）
	# typed_array = untyped_array  # 这会报错！类型化数组不支持隐式转换！
	
	# 正确示范
	var temp_typed: Array[Array] = []
	temp_typed.append_array(untyped_array)
	typed_array = temp_typed
	
	print("   ✅ 类型化数组转换成功")
	print("      转换后数组大小: ", typed_array.size())
	
	# 测试地牢数组的类型处理
	print("   测试地牢数组类型处理...")
	var api = DungeonGeneratorAPI.new()
	var dungeon_result = api.generate_dungeon(32, 32)
	
	if not dungeon_result.is_empty():
		# 显式类型转换
		var typed_dungeon: Array[Array] = []
		typed_dungeon.append_array(dungeon_result)
		
		print("   ✅ 地牢数组类型转换成功")
		print("      转换后尺寸: ", typed_dungeon.size(), " x ", typed_dungeon[0].size())
	else:
		print("   ❌ 地牢生成失败，无法测试类型转换")

## 测试基本API调用
func test_basic_api():
	var api = DungeonGeneratorAPI.new()
	
	# 测试默认参数生成
	print("   测试默认参数生成...")
	var dungeon: Array[Array] = api.generate_dungeon()
	
	if not dungeon.is_empty():
		print("   ✅ 默认参数生成成功")
		print("      地牢尺寸: ", dungeon.size(), " x ", dungeon[0].size())
		
		# 测试单元格类型访问
		var sample_cell = dungeon[dungeon.size()/2][dungeon[0].size()/2]
		print("      中心单元格类型: ", get_cell_type_name(sample_cell))
		
		# 使用工具方法获取统计信息
		var stats = api.get_grid_stats(dungeon)
		print("      覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))
		print("      房间数量(估算): %.0f" % stats["room_count"])
	else:
		print("   ❌ 默认参数生成失败")

## 测试参数化生成
func test_parameterized_generation():
	var api = DungeonGeneratorAPI.new()
	
	# 测试不同尺寸
	var test_cases = [
		{"name": "小型地牢", "width": 64, "height": 64},
		{"name": "中型地牢", "width": 128, "height": 128},
		{"name": "大型地牢", "width": 256, "height": 256},
		{"name": "宽型地牢", "width": 200, "height": 100},
		{"name": "高型地牢", "width": 100, "height": 200}
	]
	
	for case_data in test_cases:
		print("   测试", case_data["name"], "(", case_data["width"], "x", case_data["height"], ")...")
		var dungeon: Array[Array] = api.generate_dungeon(
			case_data["width"], case_data["height"]
		)
		
		if not dungeon.is_empty():
			print("      ✅ 生成成功")
			var stats = api.get_grid_stats(dungeon)
			print("         覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))
		else:
			print("      ❌ 生成失败")
	
	# 测试房间参数
	print("   测试房间参数...")
	var room_test_cases = [
		{"name": "小房间", "min_room": 4, "max_room": 8},
		{"name": "中房间", "min_room": 8, "max_room": 16},
		{"name": "大房间", "min_room": 12, "max_room": 25}
	]
	
	for case_data in room_test_cases:
		print("   测试", case_data["name"], "...")
		var dungeon = api.generate_dungeon(
			128, 128,  # 尺寸
			case_data["min_room"], case_data["max_room"]  # 房间大小
		)
		
		if not dungeon.is_empty():
			print("      ✅ 生成成功")
		else:
			print("      ❌ 生成失败")

## 测试便捷方法
func test_convenience_methods():
	var api = DungeonGeneratorAPI.new()
	
	# 测试小型地牢
	print("   测试 generate_small_dungeon()...")
	var small_dungeon: Array[Array] = api.generate_small_dungeon(64)
	if not small_dungeon.is_empty():
		print("   ✅ 小型地牢生成成功")
		print("      尺寸: ", small_dungeon.size(), " x ", small_dungeon[0].size())
	else:
		print("   ❌ 小型地牢生成失败")
	
	# 测试大型地牢
	print("   测试 generate_large_dungeon()...")
	var large_dungeon: Array[Array] = api.generate_large_dungeon(128)
	if not large_dungeon.is_empty():
		print("   ✅ 大型地牢生成成功")
		print("      尺寸: ", large_dungeon.size(), " x ", large_dungeon[0].size())
	else:
		print("   ❌ 大型地牢生成失败")
	
	# 测试密集型地牢
	print("   测试 generate_dense_dungeon()...")
	var dense_dungeon: Array[Array] = api.generate_dense_dungeon()
	if not dense_dungeon.is_empty():
		print("   ✅ 密集型地牢生成成功")
		var stats = api.get_grid_stats(dense_dungeon)
		print("      覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))
	else:
		print("   ❌ 密集型地牢生成失败")
	
	# 测试稀疏型地牢
	print("   测试 generate_sparse_dungeon()...")
	var sparse_dungeon: Array[Array] = api.generate_sparse_dungeon()
	if not sparse_dungeon.is_empty():
		print("   ✅ 稀疏型地牢生成成功")
		var stats = api.get_grid_stats(sparse_dungeon)
		print("      覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))
	else:
		print("   ❌ 稀疏型地牢生成失败")

## 测试错误处理
func test_error_handling():
	var api = DungeonGeneratorAPI.new()
	
	# 测试无效尺寸
	print("   测试无效尺寸...")
	var invalid_sizes = [
		{"width": 10, "height": 10, "desc": "太小"},
		{"width": 3000, "height": 3000, "desc": "太大"},
		{"width": 0, "height": 128, "desc": "宽度为0"},
		{"width": 128, "height": 0, "desc": "高度为0"}
	]
	
	for size_data in invalid_sizes:
		print("   测试", size_data["desc"], "尺寸 (", size_data["width"], "x", size_data["height"], ")...")
		var dungeon: Array[Array] = api.generate_dungeon(size_data["width"], size_data["height"])
		
		if dungeon.is_empty():
			print("      ✅ 正确返回空数组（应该会看到错误信息）")
		else:
			print("      ❌ 应该失败但成功了")
	
	# 测试无效房间参数
	print("   测试无效房间参数...")
	var invalid_room_params = [
		{"min_room": 2, "max_room": 50, "desc": "房间太小"},
		{"min_room": 30, "max_room": 10, "desc": "最小>最大"},
		{"min_room": 60, "max_room": 80, "desc": "房间太大"}
	]
	
	for param_data in invalid_room_params:
		print("   测试", param_data["desc"], "参数...")
		var dungeon: Array[Array] = api.generate_dungeon(
			128, 128,
			param_data["min_room"], param_data["max_room"]
		)
		
		if dungeon.is_empty():
			print("      ✅ 正确返回空数组")
		else:
			print("      ❌ 应该失败但成功了")

## 测试工具方法
func test_utility_methods():
	var api = DungeonGeneratorAPI.new()
	
	# 生成一个测试地牢
	var dungeon: Array[Array] = api.generate_dungeon(64, 64)
	
	if dungeon.is_empty():
		print("   ❌ 无法生成测试地牢，跳过工具方法测试")
		return
	
	print("   测试 grid_to_ascii()...")
	var ascii_text = api.grid_to_ascii(dungeon)
	if not ascii_text.is_empty():
		print("   ✅ ASCII转换成功")
		print("      前5行预览:")
		var lines = ascii_text.split("\n")
		for i in range(min(5, lines.size())):
			if not lines[i].is_empty():
				print("         ", lines[i])
	else:
		print("   ❌ ASCII转换失败")
	
	print("   测试 get_grid_stats()...")
	var stats = api.get_grid_stats(dungeon)
	if not stats.is_empty():
		print("   ✅ 统计信息获取成功")
		print("      总单元格: ", stats["total_cells"])
		print("      已使用: ", stats["used_cells"])
		print("      覆盖率: %.1f%%" % (stats["coverage_ratio"] * 100))
		print("      估算房间数: %.0f" % stats["room_count"])
		print("      门数量: ", stats["door_count"])
		print("      走廊长度: ", stats["corridor_length"])
	else:
		print("   ❌ 统计信息获取失败")
	
	print("   测试 print_grid()...")
	print("   地牢预览（前10x10）:")
	for y in range(min(10, dungeon.size())):
		var line = "   "
		for x in range(min(10, dungeon[0].size())):
			line += get_cell_symbol(dungeon[y][x])
		print(line)

## 测试性能
func test_performance():
	var api = DungeonGeneratorAPI.new()
	
	# 测试不同尺寸的性能
	var perf_cases = [
		{"name": "小型(64x64)", "width": 64, "height": 64, "iterations": 20},
		{"name": "中型(128x128)", "width": 128, "height": 128, "iterations": 10},
		{"name": "大型(256x256)", "width": 256, "height": 256, "iterations": 5}
	]
	
	for case_data in perf_cases:
		print("   测试", case_data["name"], "性能 (", case_data["iterations"], "次迭代)...")
		
		var start_time = Time.get_ticks_msec()
		var success_count = 0
		
		for i in range(case_data["iterations"]):
			var dungeon: Array[Array] = api.generate_dungeon(case_data["width"], case_data["height"])
			if not dungeon.is_empty():
				success_count += 1
		
		var end_time = Time.get_ticks_msec()
		var total_time = end_time - start_time
		var avg_time = total_time / case_data["iterations"]
		var success_rate = float(success_count) / case_data["iterations"] * 100
		
		print("      总时间: ", total_time, "ms")
		print("      平均时间: %.1fms" % avg_time)
		print("      成功率: %.1f%%" % success_rate)
		
		if success_rate == 100:
			print("      ✅ 性能测试通过")
		else:
			print("      ❌ 存在失败案例")

## 辅助函数：获取单元格类型名称
func get_cell_type_name(cell_type: int) -> String:
	match cell_type:
		DungeonGeneratorAPI.CellType.EMPTY:
			return "EMPTY"
		DungeonGeneratorAPI.CellType.ROOM_FLOOR:
			return "ROOM_FLOOR"
		DungeonGeneratorAPI.CellType.WALL:
			return "WALL"
		DungeonGeneratorAPI.CellType.CORRIDOR:
			return "CORRIDOR"
		DungeonGeneratorAPI.CellType.DOOR:
			return "DOOR"
		_:
			return "UNKNOWN"

## 辅助函数：获取单元格符号
func get_cell_symbol(cell_type: int) -> String:
	match cell_type:
		DungeonGeneratorAPI.CellType.EMPTY:
			return " "
		DungeonGeneratorAPI.CellType.ROOM_FLOOR:
			return "."
		DungeonGeneratorAPI.CellType.WALL:
			return "#"
		DungeonGeneratorAPI.CellType.CORRIDOR:
			return "+"
		DungeonGeneratorAPI.CellType.DOOR:
			return "D"
		_:
			return "?"

## 静态方法测试
func test_static_methods():
	print("\n7. 测试静态方法...")
	
	# 测试静态创建
	print("   测试静态创建...")
	var api = DungeonGeneratorAPI.create()
	if api:
		print("   ✅ 静态创建成功")
	else:
		print("   ❌ 静态创建失败")
	
	# 测试快速生成
	print("   测试快速生成...")
	var quick_dungeon: Array[Array] = DungeonGeneratorAPI.quick_generate(64, 64)
	if not quick_dungeon.is_empty():
		print("   ✅ 快速生成成功")
	else:
		print("   ❌ 快速生成失败")
