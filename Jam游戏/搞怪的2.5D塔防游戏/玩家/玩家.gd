extends CharacterBody3D



var 移动速度 := 10.0
@export var 相机 :Camera3D

func _physics_process(_delta: float) -> void:
	# A:左， x-   D:右， x+
	# W:前， z-   S:后， z+
	var 前后:float = Input.get_axis("w", "s")
	var 左右:float = Input.get_axis("a", "d")
	
	var 方向 := Vector2(前后, 左右).normalized() # 归一化
	前后 = 方向.x
	左右 = 方向.y
	
	self.velocity.x = 左右 * 移动速度
	self.velocity.z = 前后 * 移动速度

	move_and_slide()


func _process(_delta: float) -> void:
	_鼠标绘制器.更新状态(_鼠标正在拖动, _鼠标拖动起始点)

	_process_绘制鼠标旁物体的选择信息()
	
	ImGui.Begin("OBJ")
	ImGui.Text("MOUSE： BEGIN %s,   END %s" % [_鼠标拖动起始点, _鼠标绘制器.get_global_mouse_position()])
	
	ImGui.Text("RECT:    %s " % [Rect2(_鼠标拖动起始点, -_鼠标拖动起始点+_鼠标绘制器.get_global_mouse_position())])
	ImGui.Text("RECT:abs %s " % [Rect2(_鼠标拖动起始点, -_鼠标拖动起始点+_鼠标绘制器.get_global_mouse_position()).abs()])
	
	
	#ImGui.Text("Mouse on plane: %s" % [相机.project_position(_鼠标绘制器.get_global_mouse_position(),1.0)])
	
	
	ImGui.TextWrapped("被选中物体：%s" % [str(被选中物体)])
	#var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
	#for obj:实体 in 可选择物体列表:
		#var 屏幕位置 := 相机.unproject_position(obj.global_position)
		#ImGui.Text("屏幕位置： %s %s" % [obj, 屏幕位置])
	ImGui.End()

@onready var _鼠标绘制器 :Node2D = $鼠标选取框绘制层/鼠标绘制器 
var _鼠标正在拖动 := false
var _鼠标拖动起始点 := Vector2.ZERO


func _process_绘制鼠标旁物体的选择信息() -> void:
	var 鼠标位置 :Vector2 = _鼠标绘制器.get_global_mouse_position()
	var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
	
	#const 范围 := 5
	
	for obj:JAM_实体 in 可选择物体列表:
		var 屏幕位置 := 相机.unproject_position(obj.global_position)
		if (屏幕位置-鼠标位置).length() <= 30:
			pass

var 被选中物体 := []
func _input(_event: InputEvent) -> void:
	var 鼠标位置 :Vector2 = _鼠标绘制器.get_global_mouse_position()
	
	if Input.is_action_just_pressed("鼠标左键"):
		_鼠标拖动起始点 = 鼠标位置
		_鼠标正在拖动 = true
	
	if Input.is_action_just_released("鼠标左键"):
		被选中物体 = []
		_鼠标正在拖动 = false
		# 获取所有可选择
		var 选择矩形 := Rect2(_鼠标拖动起始点, -_鼠标拖动起始点+ 鼠标位置).abs()
		var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
		
		
		# 松手时，设置所有实体为被选中状态
		for obj:JAM_实体 in 可选择物体列表:
			var 屏幕位置 := 相机.unproject_position(obj.global_position)
			if 选择矩形.has_point(屏幕位置): 
				obj.被选择 = true
				被选中物体.append(obj)
			else:
				obj.被选择 = false
		
	
	if Input.is_action_just_pressed("鼠标右键"):
		print_debug("右键。")
		
		for i in 被选中物体:
			if i is JAM_人:
				print("是人：", i)
				pass
		
		
		被选中物体 = []
		
