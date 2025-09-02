# DebugPanelAPI.gd
# DungeonGeneratorAPI调试面板
#
# 这是一个为DungeonGeneratorAPI提供的可视化调试界面
# 支持快速生成不同类型的地牢并实时预览
#
# 主要功能：
# - 基础参数配置（尺寸、房间大小）
# - 快速生成按钮（小型、中型、大型、密集型、稀疏型）
# - ASCII字符渲染地牢地图
# - 详细的统计信息显示
#
# @author Claude Code
# @version 2.1
# @date 2025-09-01

extends Panel

# ===========================================
# UI节点引用
# ===========================================

## 基础配置控件
@onready var width_spin_box = %WidthSpinBox
@onready var height_spin_box = %HeightSpinBox
@onready var min_room_spin_box = %MinRoomSpinBox
@onready var max_room_spin_box = %MaxRoomSpinBox
@onready var font_size_spin_box = %FontSizeSpinBox

## 快速生成按钮
@onready var small_dungeon_btn = %SmallDungeonBtn
@onready var medium_dungeon_btn = %MediumDungeonBtn
@onready var large_dungeon_btn = %LargeDungeonBtn
@onready var dense_dungeon_btn = %DenseDungeonBtn
@onready var sparse_dungeon_btn = %SparseDungeonBtn

## 操作按钮
@onready var generate_btn = %GenerateBtn
@onready var reset_btn = %ResetBtn

## 显示控件
@onready var stats_label = %StatsLabel
@onready var dungeon_canvas = %DungeonCanvas

# ===========================================
# 核心变量
# ===========================================

## API实例
var api: DungeonGeneratorAPI

## 当前地牢数据
var current_dungeon: Array[Array] = []

## ASCII符号映射
var symbols = {
	DungeonGeneratorAPI.CellType.EMPTY: " ",
	DungeonGeneratorAPI.CellType.ROOM_FLOOR: ".",
	DungeonGeneratorAPI.CellType.WALL: "#",
	DungeonGeneratorAPI.CellType.CORRIDOR: "+",
	DungeonGeneratorAPI.CellType.DOOR: "D"
}

# ===========================================
# 生命周期方法
# ===========================================

## 面板初始化
func _ready():
	# 创建API实例
	api = DungeonGeneratorAPI.new()
	
	# 连接信号
	_connect_signals()
	
	# 初始化显示
	_reset_display()
	_update_font_size()

## 连接所有信号
func _connect_signals():
	# 基础配置信号
	width_spin_box.value_changed.connect(_on_width_changed)
	height_spin_box.value_changed.connect(_on_height_changed)
	min_room_spin_box.value_changed.connect(_on_min_room_changed)
	max_room_spin_box.value_changed.connect(_on_max_room_changed)
	font_size_spin_box.value_changed.connect(_on_font_size_changed)
	
	# 快速生成按钮信号
	small_dungeon_btn.pressed.connect(_on_small_dungeon_pressed)
	medium_dungeon_btn.pressed.connect(_on_medium_dungeon_pressed)
	large_dungeon_btn.pressed.connect(_on_large_dungeon_pressed)
	dense_dungeon_btn.pressed.connect(_on_dense_dungeon_pressed)
	sparse_dungeon_btn.pressed.connect(_on_sparse_dungeon_pressed)
	
	# 操作按钮信号
	generate_btn.pressed.connect(_on_generate_pressed)
	reset_btn.pressed.connect(_on_reset_pressed)

# ===========================================
# 信号处理方法
# ===========================================

## 基础配置变化处理
func _on_width_changed(value: float):
	_update_generate_button_state()

func _on_height_changed(value: float):
	_update_generate_button_state()

func _on_min_room_changed(value: float):
	_update_generate_button_state()

func _on_max_room_changed(value: float):
	_update_generate_button_state()

func _on_font_size_changed(value: float):
	_update_font_size()

## 快速生成按钮处理
func _on_small_dungeon_pressed():
	_generate_with_api("小型地牢", func():
		return api.generate_small_dungeon(64)
	)

func _on_medium_dungeon_pressed():
	_generate_with_api("中型地牢", func():
		return api.generate_dungeon(128, 128)
	)

func _on_large_dungeon_pressed():
	_generate_with_api("大型地牢", func():
		return api.generate_large_dungeon(128)
	)

func _on_dense_dungeon_pressed():
	_generate_with_api("密集型地牢", func():
		return api.generate_dense_dungeon()
	)

func _on_sparse_dungeon_pressed():
	_generate_with_api("稀疏型地牢", func():
		return api.generate_sparse_dungeon()
	)

## 操作按钮处理
func _on_generate_pressed():
	var width = int(width_spin_box.value)
	var height = int(height_spin_box.value)
	var min_room = int(min_room_spin_box.value)
	var max_room = int(max_room_spin_box.value)
	
	_generate_with_api("自定义地牢", func():
		return api.generate_dungeon(width, height, min_room, max_room)
	)

func _on_reset_pressed():
	_reset_display()

# ===========================================
# 核心生成方法
# ===========================================

## 使用API生成地牢
## @param name: 生成类型名称
## @param generator_func: 生成函数
func _generate_with_api(name: String, generator_func: Callable):
	print("开始生成", name, "...")
	
	var start_time = Time.get_ticks_msec()
	
	# 调用API生成地牢
	var dungeon: Array[Array] = generator_func.call()
	
	var end_time = Time.get_ticks_msec()
	var generation_time = end_time - start_time
	
	# 检查生成结果
	if dungeon.is_empty():
		_show_error(name + " 生成失败！请检查控制台错误信息。")
		current_dungeon = []
	else:
		print(name + " 生成成功！用时:", generation_time, "ms")
		current_dungeon = dungeon
		_show_success(name, generation_time)
	
	# 更新显示
	_update_display()

# ===========================================
# 显示更新方法
# ===========================================

## 重置显示
func _reset_display():
	current_dungeon = []
	_update_display()
	_show_welcome_message()

## 更新所有显示
func _update_display():
	_render_dungeon()
	_update_stats()

## 渲染地牢
func _render_dungeon():
	if current_dungeon.is_empty():
		dungeon_canvas.text = "[code]等待生成地牢...[/code]"
		return
	
	# 生成ASCII字符串
	var ascii_text = ""
	var grid_width = current_dungeon[0].size()
	var grid_height = current_dungeon.size()
	
	for y in range(grid_height):
		for x in range(grid_width):
			var cell_type = current_dungeon[y][x]
			ascii_text += symbols.get(cell_type, "?")
		ascii_text += "\n"
	
	# 显示ASCII地牢（不使用code标签，保持等宽字体）
	var font_size = int(font_size_spin_box.value)
	dungeon_canvas.text = "[font_size=" + str(font_size) + "]" + ascii_text + "[/font_size]"

## 更新字体大小
func _update_font_size():
	# 重新渲染地牢以应用新的字体大小
	if not current_dungeon.is_empty():
		_render_dungeon()

## 更新统计信息
func _update_stats():
	if current_dungeon.is_empty():
		stats_label.text = "[b]统计信息[/b]\n\n等待生成地牢..."
		return
	
	# 使用API的统计方法
	var stats = api.get_grid_stats(current_dungeon)
	
	var stats_text = "[b]地牢统计信息[/b]\n\n"
	stats_text += "[b]尺寸:[/b] " + str(current_dungeon.size()) + " x " + str(current_dungeon[0].size()) + "\n"
	stats_text += "[b]总单元格:[/b] " + str(stats["total_cells"]) + "\n"
	stats_text += "[b]已使用:[/b] " + str(stats["used_cells"]) + "\n"
	stats_text += "[b]覆盖率:[/b] %.1f%%\n" % (stats["coverage_ratio"] * 100)
	stats_text += "\n"
	
	stats_text += "[b]单元格统计:[/b]\n"
	stats_text += "  空白: " + str(stats["cell_counts"]["empty"]) + "\n"
	stats_text += "  房间: " + str(stats["cell_counts"]["room_floor"]) + "\n"
	stats_text += "  墙壁: " + str(stats["cell_counts"]["wall"]) + "\n"
	stats_text += "  走廊: " + str(stats["cell_counts"]["corridor"]) + "\n"
	stats_text += "  门: " + str(stats["cell_counts"]["door"]) + "\n"
	stats_text += "\n"
	
	stats_text += "[b]估算数据:[/b]\n"
	stats_text += "  房间数: %.0f\n" % stats["room_count"]
	stats_text += "  门数量: " + str(stats["door_count"]) + "\n"
	stats_text += "  走廊长度: " + str(stats["corridor_length"])
	
	stats_label.text = stats_text

# ===========================================
# UI状态管理
# ===========================================

## 更新生成按钮状态
func _update_generate_button_state():
	var min_room = int(min_room_spin_box.value)
	var max_room = int(max_room_spin_box.value)
	
	# 验证参数
	if min_room > max_room:
		generate_btn.disabled = true
		generate_btn.text = "最小房间 > 最大房间"
	elif min_room < 4 or max_room > 50:
		generate_btn.disabled = true
		generate_btn.text = "房间大小超出范围"
	else:
		generate_btn.disabled = false
		generate_btn.text = "生成地牢"

## 显示欢迎信息
func _show_welcome_message():
	stats_label.text = "[b]欢迎使用 DungeonGenerator API![/b]\n\n"
	stats_label.text += "这是一个简化的地牢生成器接口。\n\n"
	stats_label.text += "[b]快速开始:[/b]\n"
	stats_label.text += "• 点击快速生成按钮\n"
	stats_label.text += "• 或配置参数后点击生成\n\n"
	stats_label.text += "[b]API特性:[/b]\n"
	stats_label.text += "• 简化的方法调用\n"
	stats_label.text += "• 类型安全的返回值\n"
	stats_label.text += "• 内置错误处理\n"
	stats_label.text += "• 便捷的预设方法"

## 显示成功信息
func _show_success(dungeon_type: String, generation_time: int):
	var message = "[b]" + dungeon_type + " 生成成功![/b]\n\n"
	message += "生成时间: " + str(generation_time) + "ms\n"
	message += "地牢尺寸: " + str(current_dungeon.size()) + "x" + str(current_dungeon[0].size())
	
	stats_label.text = message

## 显示错误信息
func _show_error(error_message: String):
	stats_label.text = "[color=red][b]生成失败[/b][/color]\n\n" + error_message

# ===========================================
# 工具方法
# ===========================================

## 获取单元格类型名称
func _get_cell_type_name(cell_type: int) -> String:
	match cell_type:
		DungeonGeneratorAPI.CellType.EMPTY:
			return "空白"
		DungeonGeneratorAPI.CellType.ROOM_FLOOR:
			return "房间"
		DungeonGeneratorAPI.CellType.WALL:
			return "墙壁"
		DungeonGeneratorAPI.CellType.CORRIDOR:
			return "走廊"
		DungeonGeneratorAPI.CellType.DOOR:
			return "门"
		_:
			return "未知"

## 验证配置参数
func _validate_config() -> bool:
	var min_room = int(min_room_spin_box.value)
	var max_room = int(max_room_spin_box.value)
	
	if min_room > max_room:
		push_error("最小房间大小不能大于最大房间大小")
		return false
	
	if min_room < 4:
		push_error("最小房间大小不能小于4")
		return false
	
	if max_room > 50:
		push_error("最大房间大小不能大于50")
		return false
	
	return true
