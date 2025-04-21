extends Node2D

# 网格尺寸
const WIDTH = 100
const HEIGHT = 100
const CELL_SIZE = 4  # 每个粒子的像素大小

# 粒子类型枚举
enum CellType {EMPTY, SAND, WATER, WALL}

# 网格数组，存储所有粒子
var grid = []

# 用于可视化的图像
var image: Image
var texture: ImageTexture
var sprite: Sprite2D

# 性能优化变量
var simulation_speed = 1  # 可以调整模拟速度
var frame_counter = 0

func _ready():
	# 初始化网格，全部设为空
	grid = []
	for x in range(WIDTH):
		var column = []
		for y in range(HEIGHT):
			column.append(CellType.EMPTY)
		grid.append(column)
	
	# 创建图像用于显示
	image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(image)
	
	# 创建并添加精灵
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(CELL_SIZE, CELL_SIZE)
	add_child(sprite)

# 在指定位置生成沙子
func spawn_sand(pos):
	var grid_x = int(pos.x / CELL_SIZE)
	var grid_y = int(pos.y / CELL_SIZE)
	if grid_x >= 0 and grid_x < WIDTH and grid_y >= 0 and grid_y < HEIGHT:
		grid[grid_x][grid_y] = CellType.SAND

# 在指定位置生成水
func spawn_water(pos):
	var grid_x = int(pos.x / CELL_SIZE)
	var grid_y = int(pos.y / CELL_SIZE)
	if grid_x >= 0 and grid_x < WIDTH and grid_y >= 0 and grid_y < HEIGHT:
		grid[grid_x][grid_y] = CellType.WATER

# 在指定位置生成墙
func spawn_wall(pos):
	var grid_x = int(pos.x / CELL_SIZE)
	var grid_y = int(pos.y / CELL_SIZE)
	if grid_x >= 0 and grid_x < WIDTH and grid_y >= 0 and grid_y < HEIGHT:
		grid[grid_x][grid_y] = CellType.WALL

# 清除指定位置的粒子
func erase_particle(pos):
	var grid_x = int(pos.x / CELL_SIZE)
	var grid_y = int(pos.y / CELL_SIZE)
	if grid_x >= 0 and grid_x < WIDTH and grid_y >= 0 and grid_y < HEIGHT:
		grid[grid_x][grid_y] = CellType.EMPTY

# 模拟粒子行为
func simulate():
	# 创建一个更新标记数组，避免一帧内多次更新同一粒子
	var updated = []
	for x in range(WIDTH):
		var column = []
		for y in range(HEIGHT):
			column.append(false)
		updated.append(column)
	
	# 从底部向上遍历，这样沙子的下落更自然
	for y in range(HEIGHT - 1, -1, -1):
		for x in range(WIDTH):
			# 墙壁不移动
			if grid[x][y] == CellType.WALL:
				continue
				
			# 沙子的行为
			if grid[x][y] == CellType.SAND and not updated[x][y]:
				# 如果下方为空，则下落
				if y < HEIGHT - 1 and grid[x][y + 1] == CellType.EMPTY:
					grid[x][y] = CellType.EMPTY
					grid[x][y + 1] = CellType.SAND
					updated[x][y + 1] = true
				# 如果下方是水，则交换位置（沙子下沉）
				elif y < HEIGHT - 1 and grid[x][y + 1] == CellType.WATER:
					grid[x][y] = CellType.WATER
					grid[x][y + 1] = CellType.SAND
					updated[x][y] = true
					updated[x][y + 1] = true
				# 如果下方被阻挡，尝试向左下或右下滑动
				elif y < HEIGHT - 1:
					# 随机选择先尝试左边还是右边，增加自然感
					var try_left_first = randf() > 0.5
					
					if try_left_first:
						# 尝试左下
						if x > 0 and grid[x - 1][y + 1] == CellType.EMPTY:
							grid[x][y] = CellType.EMPTY
							grid[x - 1][y + 1] = CellType.SAND
							updated[x - 1][y + 1] = true
						# 尝试右下
						elif x < WIDTH - 1 and grid[x + 1][y + 1] == CellType.EMPTY:
							grid[x][y] = CellType.EMPTY
							grid[x + 1][y + 1] = CellType.SAND
							updated[x + 1][y + 1] = true
					else:
						# 先尝试右下
						if x < WIDTH - 1 and grid[x + 1][y + 1] == CellType.EMPTY:
							grid[x][y] = CellType.EMPTY
							grid[x + 1][y + 1] = CellType.SAND
							updated[x + 1][y + 1] = true
						# 再尝试左下
						elif x > 0 and grid[x - 1][y + 1] == CellType.EMPTY:
							grid[x][y] = CellType.EMPTY
							grid[x - 1][y + 1] = CellType.SAND
							updated[x - 1][y + 1] = true
			
			# 水的行为
			elif grid[x][y] == CellType.WATER and not updated[x][y]:
				# 水向下流动
				if y < HEIGHT - 1 and grid[x][y + 1] == CellType.EMPTY:
					grid[x][y] = CellType.EMPTY
					grid[x][y + 1] = CellType.WATER
					updated[x][y + 1] = true
				else:
					# 水向两侧流动
					var moved = false
					var try_left_first = randf() > 0.5
					
					if try_left_first:
						# 尝试左下和右下
						if y < HEIGHT - 1:
							if x > 0 and grid[x - 1][y + 1] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x - 1][y + 1] = CellType.WATER
								updated[x - 1][y + 1] = true
								moved = true
							elif x < WIDTH - 1 and grid[x + 1][y + 1] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x + 1][y + 1] = CellType.WATER
								updated[x + 1][y + 1] = true
								moved = true
						
						# 如果无法向下流动，尝试向左右流动
						if not moved:
							if x > 0 and grid[x - 1][y] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x - 1][y] = CellType.WATER
								updated[x - 1][y] = true
							elif x < WIDTH - 1 and grid[x + 1][y] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x + 1][y] = CellType.WATER
								updated[x + 1][y] = true
					else:
						# 先尝试右下和左下
						if y < HEIGHT - 1:
							if x < WIDTH - 1 and grid[x + 1][y + 1] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x + 1][y + 1] = CellType.WATER
								updated[x + 1][y + 1] = true
								moved = true
							elif x > 0 and grid[x - 1][y + 1] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x - 1][y + 1] = CellType.WATER
								updated[x - 1][y + 1] = true
								moved = true
						
						# 如果无法向下流动，尝试向右左流动
						if not moved:
							if x < WIDTH - 1 and grid[x + 1][y] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x + 1][y] = CellType.WATER
								updated[x + 1][y] = true
							elif x > 0 and grid[x - 1][y] == CellType.EMPTY:
								grid[x][y] = CellType.EMPTY
								grid[x - 1][y] = CellType.WATER
								updated[x - 1][y] = true

# 更新图像
func update_image():
	for y in range(HEIGHT):
		for x in range(WIDTH):
			match grid[x][y]:
				CellType.EMPTY:
					image.set_pixel(x, y, Color(0, 0, 0, 0))  # 透明
				CellType.SAND:
					image.set_pixel(x, y, Color(0.76, 0.7, 0.5, 1))  # 沙色
				CellType.WATER:
					image.set_pixel(x, y, Color(0.2, 0.3, 0.8, 0.8))  # 蓝色半透明
				CellType.WALL:
					image.set_pixel(x, y, Color(0.3, 0.3, 0.3, 1.0))  # 灰色
	
	texture.update(image)

func _process(_delta):
	frame_counter += 1
	
	# 根据模拟速度决定是否进行模拟
	if frame_counter % simulation_speed == 0:
		simulate()
	
	# 更新图像
	update_image()
