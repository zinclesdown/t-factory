extends CharacterBody3D
class_name JAM_玩家



var 移动速度 := 10.0
@export var 相机 :Camera3D
@onready var 鼠标选择用射线: RayCast3D = %"鼠标与地面接触用射线"
@onready var 鼠标选择示意球: MeshInstance3D = %"鼠标选择示意球"
@onready var 选择实体用射线: RayCast3D = %"选择实体用射线"

@onready var 相机旋转margin: Marker3D = %相机旋转Margin


static var 单例:JAM_玩家

func _ready() -> void:
	单例 = self

## 更新两条射线的方向。
func _process_更新射线() -> void:
	var 相机法向 := 相机.project_local_ray_normal(获取鼠标屏幕位置())
	var 射线目的地 := 相机法向 * 100
	鼠标选择用射线.target_position = 射线目的地
	选择实体用射线.target_position = 射线目的地


static func 获取鼠标屏幕位置() -> Vector2:
	return 单例._鼠标绘制器.get_local_mouse_position()

## 主要用于定位鼠标在3d地图里的位置。
static func 获取鼠标与3d选择面相交位置() -> Vector3:
	return 单例.鼠标选择用射线.get_collision_point()

static func 获取当前鼠标悬浮的单位() -> Node:
	var collider :Node = 单例.选择实体用射线.get_collider()
	if is_instance_valid(collider):
		if collider.is_in_group("可选择物"):
			return collider
	return


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
	_process_更新射线()
	_鼠标绘制器.更新状态(_鼠标正在拖动, _鼠标拖动起始点)
	_process_绘制鼠标旁物体的选择信息()
	
	ImGui.Begin("玩家面板")
	ImGui.Text("Col: %s" % [str(鼠标选择用射线.get_collision_point())])
	鼠标选择示意球.global_position =  获取鼠标与3d选择面相交位置()
	
	ImGui.TextWrapped("被选中物体：%s" % [str(获取被选中物体列表())])
	ImGui.TextWrapped("被选中物体：%s" % [str(获取被选中物体列表())])
	#var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
	#for obj:实体 in 可选择物体列表:
		#var 屏幕位置 := 相机.unproject_position(obj.global_position)
		#ImGui.Text("屏幕位置： %s %s" % [obj, 屏幕位置])
	ImGui.End()


@onready var _鼠标绘制器 :Node2D = $鼠标选取框绘制层/鼠标绘制器 
var _鼠标正在拖动 := false
var _鼠标拖动起始点 := Vector2.ZERO


func _process_绘制鼠标旁物体的选择信息() -> void:
	#var 鼠标位置 :Vector2 = _鼠标绘制器.get_global_mouse_position()
	#var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
	
	
	for i in 获取高亮的物体列表():
		i.remove_from_group("被高亮物")
	
	if is_instance_valid(选择实体用射线) and 选择实体用射线.get_collider():
		var collider :Node= 选择实体用射线.get_collider()
		if collider.is_in_group("可选择物"):
			#print(collider)
			collider.add_to_group("被高亮物")
	
		#for i in 选择实体用射线.get_collider():
			#print(i)
	
	#for obj:JAM_实体 in 可选择物体列表:
		#var 屏幕位置 := 相机.unproject_position(obj.global_position)
		#if (屏幕位置-鼠标位置).length() <= 30:
			#pass




func 获取被选中物体列表() -> Array[Node]:
	return get_tree().get_nodes_in_group("被选择物")

func 获取高亮的物体列表() -> Array[Node]:
	return get_tree().get_nodes_in_group("被高亮物")


#var 被选中物体 := []
#func _input(_event: InputEvent) -> void:
#
		#


func _unhandled_input(event: InputEvent) -> void:
	var 鼠标位置 :Vector2 = _鼠标绘制器.get_global_mouse_position()
	
	if Input.is_action_just_pressed("鼠标左键"):
		_鼠标拖动起始点 = 鼠标位置
		_鼠标正在拖动 = true
	
	if Input.is_action_just_released("鼠标左键"):
		#被选中物体 = []
		_鼠标正在拖动 = false
		# 获取所有可选择
		var 选择矩形 := Rect2(_鼠标拖动起始点, -_鼠标拖动起始点+ 鼠标位置).abs()
		var 可选择物体列表 := get_tree().get_nodes_in_group("可选择物")
		
		# 松手时，设置所有实体为被选中状态
		for obj:JAM_实体 in 可选择物体列表:
			var 屏幕位置 := 相机.unproject_position(obj.global_position)
			if 选择矩形.has_point(屏幕位置): 
				obj.add_to_group("被选择物")
			else:
				obj.remove_from_group("被选择物")
	
	if Input.is_action_just_pressed("鼠标右键"):
		print_debug("右键。", 获取当前鼠标悬浮的单位())
		if 获取当前鼠标悬浮的单位() is JAM_资源:
			get_tree().call_group("被选择物", "命令采矿", 获取当前鼠标悬浮的单位())
		else:
			get_tree().call_group("被选择物", "命令移动", 获取鼠标与3d选择面相交位置())


	var 鼠标滚轮输入 := Input.get_axis("鼠标滚轮上", "鼠标滚轮下")
	相机旋转margin.rotation.x += 鼠标滚轮输入/180.0 * 20.0
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("鼠标中键"):
			global_position.x -= event.relative.x * 0.05
			global_position.z -= event.relative.y * 0.05
			
	
