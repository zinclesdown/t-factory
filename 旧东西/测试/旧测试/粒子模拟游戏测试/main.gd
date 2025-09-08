extends Node2D

@onready var particle_system = $ParticleSystem

enum ParticleType {SAND, WATER, WALL, ERASER}
var current_particle = ParticleType.SAND

func _ready():
	# 设置UI按钮
	$UI/SandButton.pressed.connect(func(): current_particle = ParticleType.SAND)
	$UI/WaterButton.pressed.connect(func(): current_particle = ParticleType.WATER)
	$UI/WallButton.pressed.connect(func(): current_particle = ParticleType.WALL)
	$UI/EraseButton.pressed.connect(func(): current_particle = ParticleType.ERASER)
	
	# 设置速度调节器
	$UI/CenterContainer/SpeedSlider.value_changed.connect(func(value): particle_system.simulation_speed = int(value))

func _process(_delta):
	# 鼠标处理
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		
		# 检查鼠标是否在UI区域外
		var ui_rect = Rect2(Vector2.ZERO, $UI.size)
		if not ui_rect.has_point(mouse_pos):
			match current_particle:
				ParticleType.SAND:
					particle_system.spawn_sand(mouse_pos)
				ParticleType.WATER:
					particle_system.spawn_water(mouse_pos)
				ParticleType.WALL:
					particle_system.spawn_wall(mouse_pos)
				ParticleType.ERASER:
					particle_system.erase_particle(mouse_pos)
	
	# 更新当前工具显示
	$UI/CurrentTool.text = "当前工具: " + ["沙子", "水", "墙壁", "橡皮擦"][current_particle]
	$UI/FPSLabel.text = "FPS: %s" % [1.0/_delta]
