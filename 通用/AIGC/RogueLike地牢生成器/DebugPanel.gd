# DebugPanel.gd
# 地牢生成器调试面板

extends Panel

# UI节点引用
@onready var stats_label = %StatsLabel
@onready var dungeon_canvas: RichTextLabel = %DungeonCanvas

# 配置控件
@onready var width_spin_box = %WidthSpinBox
@onready var height_spin_box = %HeightSpinBox
@onready var min_room_size_spin_box = %MinRoomSizeSpinBox
@onready var max_room_size_spin_box = %MaxRoomSizeSpinBox
@onready var min_room_distance_spin_box = %MinRoomDistanceSpinBox

# 按钮控件
@onready var generate_btn = %GenerateBtn
@onready var step1_btn = %Step1Btn
@onready var step2_btn = %Step2Btn
@onready var step3_btn = %Step3Btn
@onready var step4_btn = %Step4Btn
@onready var step5_btn = %Step5Btn
@onready var reset_btn = %ResetBtn

# 地牢生成器
var generator: DungeonGenerator

# 调试状态
var debug_step = 0
var debug_data = {
	"grid": [],
	"rooms": [],
	"connections": [],
	"doors": []
}

## ASCII符号
var symbols = {
	DungeonGenerator.CellType.EMPTY: " ",
	DungeonGenerator.CellType.ROOM_FLOOR: ".",
	DungeonGenerator.CellType.WALL: "#",
	DungeonGenerator.CellType.CORRIDOR: "+",
	DungeonGenerator.CellType.DOOR: "D"
}

func _ready():
	# 创建配置对象并设置初始值
	var config = DungeonGenerator.DungeonConfig.new()
	config.width = int(width_spin_box.value)
	config.height = int(height_spin_box.value)
	config.min_room_size = int(min_room_size_spin_box.value)
	config.max_room_size = int(max_room_size_spin_box.value)
	config.min_room_distance = int(min_room_distance_spin_box.value)
	
	# 初始化生成器
	generator = DungeonGenerator.new(config)
	
	# 初始化地牢
	_reset_dungeon()
	
	# 更新按钮状态
	_update_button_states()

func _update_config_from_ui():
	"""从UI更新配置"""
	var config = generator.config
	config.width = int(width_spin_box.value)
	config.height = int(height_spin_box.value)
	config.min_room_size = int(min_room_size_spin_box.value)
	config.max_room_size = int(max_room_size_spin_box.value)
	config.min_room_distance = int(min_room_distance_spin_box.value)

func _reset_dungeon():
	"""重置地牢"""
	debug_step = 0
	debug_data = {
		"grid": [],
		"rooms": [],
		"connections": [],
		"doors": []
	}
	
	# 创建空网格
	var grid = []
	for y in range(generator.config.height):
		var row = []
		for x in range(generator.config.width):
			row.append(DungeonGenerator.CellType.EMPTY)
		grid.append(row)
	
	debug_data.grid = grid
	_render_grid()
	_update_stats()
	_update_button_states()

func _render_grid():
	"""渲染地牢网格到ASCII"""
	if not dungeon_canvas or debug_data.grid.is_empty():
		return
	
	# 限制显示尺寸以避免性能问题
	var max_display_width = 80
	var max_display_height = 40
	
	var grid_width = debug_data.grid[0].size()
	var grid_height = debug_data.grid.size()
	
	# 计算缩放比例
	var scale = 1
	if grid_width > max_display_width or grid_height > max_display_height:
		scale = max(1, min(max_display_width / grid_width, max_display_height / grid_height))
	
	var display_width = int(grid_width * scale)
	var display_height = int(grid_height * scale)
	
	# 生成ASCII字符串
	var ascii_text = ""
	for y in range(0, grid_height, int(1.0 / scale)):
		for x in range(0, grid_width, int(1.0 / scale)):
			var cell_type = debug_data.grid[y][x]
			ascii_text += symbols.get(cell_type, "?")
		ascii_text += "\n"
	
	# 使用等宽字体显示
	dungeon_canvas.text = "[code]" + ascii_text + "[/code]"

func _update_button_states():
	"""更新按钮状态"""
	# 禁用所有步骤按钮
	step1_btn.disabled = debug_step >= 1
	step2_btn.disabled = debug_step >= 2 or debug_step < 1
	step3_btn.disabled = debug_step >= 3 or debug_step < 2
	step4_btn.disabled = debug_step >= 4 or debug_step < 3
	step5_btn.disabled = debug_step >= 5 or debug_step < 4
	
	# 高亮当前步骤
	if debug_step == 0:
		step1_btn.modulate = Color.WHITE
		step2_btn.modulate = Color.GRAY
		step3_btn.modulate = Color.GRAY
		step4_btn.modulate = Color.GRAY
		step5_btn.modulate = Color.GRAY
	elif debug_step == 1:
		step1_btn.modulate = Color.GREEN
		step2_btn.modulate = Color.WHITE
		step3_btn.modulate = Color.GRAY
		step4_btn.modulate = Color.GRAY
		step5_btn.modulate = Color.GRAY
	elif debug_step == 2:
		step1_btn.modulate = Color.GREEN
		step2_btn.modulate = Color.GREEN
		step3_btn.modulate = Color.WHITE
		step4_btn.modulate = Color.GRAY
		step5_btn.modulate = Color.GRAY
	elif debug_step == 3:
		step1_btn.modulate = Color.GREEN
		step2_btn.modulate = Color.GREEN
		step3_btn.modulate = Color.GREEN
		step4_btn.modulate = Color.WHITE
		step5_btn.modulate = Color.GRAY
	elif debug_step == 4:
		step1_btn.modulate = Color.GREEN
		step2_btn.modulate = Color.GREEN
		step3_btn.modulate = Color.GREEN
		step4_btn.modulate = Color.GREEN
		step5_btn.modulate = Color.WHITE
	else:
		step1_btn.modulate = Color.GREEN
		step2_btn.modulate = Color.GREEN
		step3_btn.modulate = Color.GREEN
		step4_btn.modulate = Color.GREEN
		step5_btn.modulate = Color.GREEN

func _update_stats():
	"""更新统计信息"""
	var stats_text = "[b]当前步骤:[/b] %d/5\n\n" % debug_step
	
	if debug_data.rooms.size() > 0:
		stats_text += "[b]房间数量:[/b] %d\n" % debug_data.rooms.size()
	
	if debug_data.connections.size() > 0:
		var mst_count = 0
		var extra_count = 0
		for conn in debug_data.connections:
			if conn["type"] == "mst":
				mst_count += 1
			else:
				extra_count += 1
		stats_text += "[b]连接数量:[/b] %d (MST: %d, 额外: %d)\n" % [debug_data.connections.size(), mst_count, extra_count]
	
	if debug_data.doors.size() > 0:
		stats_text += "[b]门数量:[/b] %d\n" % debug_data.doors.size()
	
	# 计算单元格统计
	var cell_counts = {
		"empty": 0,
		"room_floor": 0,
		"wall": 0,
		"corridor": 0,
		"door": 0
	}
	
	for row in debug_data.grid:
		for cell in row:
			match cell:
				DungeonGenerator.CellType.EMPTY:
					cell_counts["empty"] += 1
				DungeonGenerator.CellType.ROOM_FLOOR:
					cell_counts["room_floor"] += 1
				DungeonGenerator.CellType.WALL:
					cell_counts["wall"] += 1
				DungeonGenerator.CellType.CORRIDOR:
					cell_counts["corridor"] += 1
				DungeonGenerator.CellType.DOOR:
					cell_counts["door"] += 1
	
	var total_cells = generator.config.width * generator.config.height
	var used_cells = total_cells - cell_counts["empty"]
	stats_text += "\n[b]单元格统计:[/b]\n"
	stats_text += "  空白: %d\n" % cell_counts["empty"]
	stats_text += "  房间: %d\n" % cell_counts["room_floor"]
	stats_text += "  墙壁: %d\n" % cell_counts["wall"]
	stats_text += "  走廊: %d\n" % cell_counts["corridor"]
	stats_text += "  门: %d\n" % cell_counts["door"]
	stats_text += "\n[b]覆盖率:[/b] %.1f%%" % (used_cells * 100.0 / total_cells)
	
	stats_label.text = stats_text

# 信号处理函数
func _on_width_spin_box_value_changed(value):
	_update_config_from_ui()
	if debug_step == 0:
		_reset_dungeon()

func _on_height_spin_box_value_changed(value):
	_update_config_from_ui()
	if debug_step == 0:
		_reset_dungeon()

func _on_min_room_size_spin_box_value_changed(value):
	_update_config_from_ui()

func _on_max_room_size_spin_box_value_changed(value):
	_update_config_from_ui()

func _on_min_room_distance_spin_box_value_changed(value):
	_update_config_from_ui()

func _on_generate_btn_pressed():
	"""生成完整地牢"""
	# 更新配置
	_update_config_from_ui()
	
	# 使用当前配置创建新的生成器
	var config = generator.config.clone()
	generator = DungeonGenerator.new(config)
	
	# 生成地牢
	var result = generator.generate()
	
	if result["success"]:
		debug_data = result["value"]
		debug_step = 5
		_render_grid()
		_update_stats()
		_update_button_states()

func _on_step_1_btn_pressed():
	"""步骤1: 初始化BSP树"""
	# 更新配置
	_update_config_from_ui()
	
	# 创建新的生成器
	generator = DungeonGenerator.new(generator.config)
	
	# 初始化网格
	generator._init_grid()
	debug_data.grid = generator.grid
	
	debug_step = 1
	_render_grid()
	_update_stats()
	_update_button_states()

func _on_step_2_btn_pressed():
	"""步骤2: 生成房间"""
	# 创建BSP树
	var leaves = generator._create_bsp_tree()
	
	# 生成房间
	var rooms = generator._generate_rooms_in_leaves(leaves)
	generator.rooms = rooms
	debug_data.rooms = rooms
	
	# 放置房间到网格
	generator._place_rooms_on_grid()
	debug_data.grid = generator.grid
	
	debug_step = 2
	_render_grid()
	_update_stats()
	_update_button_states()

func _on_step_3_btn_pressed():
	"""步骤3: 连接房间"""
	# 连接房间
	generator._connect_rooms()
	# 转换为字典数组
	debug_data.connections = []
	for conn in generator.connections:
		debug_data.connections.append(conn.to_dict())
	debug_data.grid = generator.grid
	
	debug_step = 3
	_render_grid()
	_update_stats()
	_update_button_states()

func _on_step_4_btn_pressed():
	"""步骤4: 放置门"""
	# 放置门
	generator._place_doors()
	generator._trim_isolated_doors()
	# 转换为字典数组
	debug_data.doors = []
	for door in generator.doors:
		debug_data.doors.append(door.to_dict())
	debug_data.grid = generator.grid
	
	debug_step = 4
	_render_grid()
	_update_stats()
	_update_button_states()

func _on_step_5_btn_pressed():
	"""步骤5: 添加墙壁"""
	# 添加墙壁
	generator._add_walls()
	debug_data.grid = generator.grid
	
	debug_step = 5
	_render_grid()
	_update_stats()
	_update_button_states()

func _on_reset_btn_pressed():
	"""重置调试"""
	_reset_dungeon()