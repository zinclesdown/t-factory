# DungeonTest.gd
# 使用EditorScript在编辑器中测试地牢生成器

@tool
extends EditorScript

## 在编辑器中运行测试
func _run():
	print("=== 地牢生成器测试 ===")
	
	# 测试1: 基本生成
	print("\n1. 测试基本生成...")
	var generator = DungeonGenerator.create_test_generator(64, 64)
	var result = generator.generate()
	
	if result["success"]:
		var data = result["value"]
		print("✅ 生成成功!")
		print("   房间数量: ", data["stats"]["room_count"])
		print("   连接数量: ", data["stats"]["connection_count"])
		print("   门数量: ", data["stats"]["door_count"])
		print("   覆盖率: ", "%.1f%%" % (data["stats"]["coverage_ratio"] * 100))
		
		# 打印ASCII预览
		print("\n   ASCII预览:")
		print("   " + "─".repeat(30))
		DungeonGenerator.print_grid_ascii(data["grid"], generator.config)
		print("   " + "─".repeat(30))
	else:
		print("❌ 生成失败: ", result["message"])
	
	# 测试2: 错误处理
	print("\n2. 测试错误处理...")
	var error_config = DungeonGenerator.DungeonConfig.new()
	error_config.width = 10  # 太小
	error_config.height = 10
	
	var errors = error_config.validate()
	if not errors.is_empty():
		print("✅ 正确捕获配置错误: ", errors[0])
	else:
		print("❌ 应该检测到配置错误但没有")
	
	# 测试3: 不同尺寸
	print("\n3. 测试不同尺寸...")
	var sizes = [[50, 50], [128, 128], [256, 256]]
	
	for size in sizes:
		print("\n   测试尺寸: ", size[0], "x", size[1])
		var size_generator = DungeonGenerator.create_test_generator(size[0], size[1])
		var size_result = size_generator.generate()
		
		if size_result["success"]:
			var size_data = size_result["value"]
			print("     房间: ", size_data["stats"]["room_count"])
			print("     用时: ", "%.1fms" % size_data["stats"]["last_generation_time"])
		else:
			print("     ❌ 失败: ", size_result["message"])
	
	# 测试4: 配置调整
	print("\n4. 测试配置调整...")
	var config_generator = DungeonGenerator.create_test_generator(100, 100)
	
	var options = {
		"min_room_size": 10,
		"max_room_size": 15,
		"min_room_distance": 5,
		"extra_connection_ratio": 0.5
	}
	
	errors = config_generator.update_config(options)
	if errors.is_empty():
		print("✅ 配置更新成功")
		var config_result = config_generator.generate()
		if config_result["success"]:
			var config_data = config_result["value"]
			print("   新配置下的房间数: ", config_data["stats"]["room_count"])
			print("   连接数: ", config_data["stats"]["connection_count"])
	else:
		if not errors.is_empty():
			print("❌ 配置更新失败: ", errors[0])
		else:
			print("❌ 配置更新失败: 未知错误")
	
	# 测试5: 性能测试
	print("\n5. 性能测试...")
	var perf_start = Time.get_ticks_msec()
	var perf_count = 10
	
	for i in range(perf_count):
		var perf_generator = DungeonGenerator.create_test_generator(128, 128)
		var perf_result = perf_generator.generate()
		if not perf_result["success"]:
			print("❌ 性能测试失败")
			break
	
	var perf_end = Time.get_ticks_msec()
	var avg_time = (perf_end - perf_start) / perf_count
	print("✅ 平均生成时间: ", "%.1fms" % avg_time)
	
	print("\n=== 测试完成 ===")
