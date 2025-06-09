extends Node2D
## 2D工厂物流系统.

## 1. 定义工厂   Producer
## 2. 定义连接器 Connector
## 3. 进行寻路   Path Finder
## 4. 进行帧Tick Tick

const 网格大小 := 32


## 每个节点有如下属性：
class 物流节点类:
	var 位置 := Vector2.ZERO
	var 被选中 := false
	var 连接的节点 :Array[物流节点类] = []
	
	func _to_string() -> String:
		return "<物流节点 %s>" % [str(Vector2i(位置))]

	func _notification(what: int) -> void:
		if what==NOTIFICATION_PREDELETE:
			print("调用了析构函数.")
			#for i in 连接的节点:

	func 连接(目标节点:物流节点类)->void:
		if 连接的节点.has(目标节点):
			print("已经建立连接了,无需重复连接.")
			return
		else:
			连接的节点.append(目标节点)
			目标节点.连接(self)
			print("成功建立连接.")

	func _debug_info()->String:
		return "<物流节点: %s>\n位置: %s\n连接: %s" % [str("节点"), str(位置), str(连接的节点)]
	
	func 析构() -> void:
		self.被选中 = false
		for i in self.连接的节点:
			i.连接的节点.erase(self)


var 节点列表 :Array[物流节点类] = []


func 获取当前选中的节点() -> Array[物流节点类]:
	return 节点列表.filter(func(a:物流节点类)->bool: return a.被选中==true)

## 会取消其他所有节点的选择状态.
func 单选选中节点(节点:物流节点类) -> void:
	for i in 节点列表:
		i.被选中 = false
	if is_instance_valid(节点):
		节点.被选中 = true


var 操作模式 := "放置节点" # "移除节点" # 建立连接

func _process(_delta: float) -> void:
	_imgui_process()
	queue_redraw()

class 物流测试存储类 extends Resource:
	@export var 节点列表 := []


func _imgui_process():
	ImGui.Begin("物流测试")
	
	if ImGui.Button("保存"):
		print(节点列表)
		#节点列表.save
		var res = 物流测试存储类.new()
		res.节点列表 = 节点列表
		ResourceSaver.save(res, "res://export/tmp/测试.tres")
	ImGui.SameLine()
	if ImGui.Button("读取"):
		pass
	ImGui.Separator()
	
	ImGui.BeginGroup()
	ImGui.Text("操作模式: %s" % [操作模式])
	if ImGui.Button("放置节点"):
		操作模式 = "放置节点"
	ImGui.SameLine()
	if ImGui.Button("移除节点"):
		操作模式 = "移除节点"
	ImGui.SameLine()
	if ImGui.Button("建立连接"):
		操作模式 = "建立连接"
	ImGui.EndGroup()
	
	#ImGui.ShowDemoWindow()
	
	ImGui.BeginListBox("物流节点")
	for i:物流节点类 in 节点列表:
		if ImGui.Selectable(str(i)):
			单选选中节点(i)
	ImGui.EndListBox()
	
	
	ImGui.BeginChild("物流节点信息", Vector2(256, 200), ImGui.ChildFlags_Borders)
	
	for i in 获取当前选中的节点():
		ImGui.TextWrapped(i._debug_info())
	ImGui.EndChild()
	
	ImGui.End()

func _获取吸附到中央的鼠标位置() -> Vector2:
	var pos := get_global_mouse_position()
	var grid := float(网格大小)
	pos = floor(pos / grid) * grid + Vector2(grid/2.0,grid/2.0)
	return pos

func _获取位置上的物流节点(位置:Vector2) -> 物流节点类:
	for i in 节点列表:
		if i.位置 == 位置:
			return i
	return
	
func _draw() -> void:
	for i in 节点列表:
		if i.被选中:
			draw_circle(i.位置, 8.0, Color.GREEN)
		else:
			draw_circle(i.位置, 8.0, Color.RED)
		
		for c in i.连接的节点:
			var begin := c.位置
			var end := i.位置
			
			draw_line(begin, end, Color.RED)
			


func _unhandled_input(_event: InputEvent) -> void:
	match 操作模式:
		"放置节点":
			if Input.is_action_just_pressed("放置构筑物"):
				var 位置 := _获取吸附到中央的鼠标位置()
				var 物流节点 := 物流节点类.new()
				
				# 防止重叠. 拒绝放置重叠节点.
				if is_instance_valid(_获取位置上的物流节点(位置)):
						print_debug("无法放置! 重叠!")
						return
				
				# 判断完毕,可以防止
				print_debug("尝试放置物流节点 %s 到 %s 位置" % [物流节点, 位置])
				物流节点.位置 = 位置
				节点列表.append(物流节点)
		
		"移除节点":
			if Input.is_action_just_pressed("放置构筑物"):
				var 位置 := _获取吸附到中央的鼠标位置()
				var 物流节点 := _获取位置上的物流节点(位置)
				if is_instance_valid(物流节点):
					节点列表.erase(物流节点)
					物流节点.析构()
		
		"建立连接":
			if Input.is_action_just_pressed("放置构筑物"):
				var 位置 := _获取吸附到中央的鼠标位置()
				var 物流节点 :物流节点类 = _获取位置上的物流节点(位置)
				if is_instance_valid(物流节点):
					if 获取当前选中的节点().size() >= 1:
						print_debug("尝试连接.")
						获取当前选中的节点()[0].连接(物流节点)
						单选选中节点(null)
					else:
						单选选中节点(物流节点)
						print_debug("请选择第二个节点.")
				else:
					单选选中节点(null)
