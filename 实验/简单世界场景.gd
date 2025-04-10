extends Node2D




@export var 可放置建筑层: 可放置建筑层实例


var 当前鼠标图块坐标:Vector2i
var 图块大小 := Vector2i(32, 32)

var _当前手上的蓝图实例: 构筑物蓝图实例 ## 玩家手里拿着的蓝图. 即将用于部署.

@export var 蓝图显示层:Node2D ## 蓝图在这里显示


func _process(_delta: float) -> void:
	当前鼠标图块坐标 = Vector2i(
		floori(get_global_mouse_position().x / 图块大小.x), 
		floori(get_global_mouse_position().y / 图块大小.y)
	) 
	
	%鼠标Label.text = '当前图块' + str(当前鼠标图块坐标)
	%"鼠标跟随".global_position = %"鼠标跟随".get_global_mouse_position()
	
	
	queue_redraw() # 绘制放置框

	%构筑物表信息.text = ""
	%构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._位置到构筑物的映射字典) + "\n"
	%构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._构筑物根位置信息) + "\n"

	# 蓝图对其鼠标
	蓝图显示层.position = 当前鼠标图块坐标*图块大小


## 绘制 "放置框"
func _draw() -> void:
	if _当前手上的蓝图实例:
		var 构筑物大小X := _当前手上的蓝图实例.构筑物大小.x
		var 构筑物大小Y := _当前手上的蓝图实例.构筑物大小.y
		
		var 颜色:Color
		if 可放置建筑层.是否可在位置放置构筑物实例_Atom(_当前手上的蓝图实例, 当前鼠标图块坐标):
			颜色 = Color.GREEN
		else:
			颜色 = Color.RED
		
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0          ,0          )), 图块大小*(当前鼠标图块坐标+Vector2i(0          ,构筑物大小Y)), 颜色, 4)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0          ,构筑物大小Y)), 图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,构筑物大小Y)), 颜色, 4)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,构筑物大小Y)), 图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,0          )), 颜色, 4)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,0          )), 图块大小*(当前鼠标图块坐标+Vector2i(0          ,0          )), 颜色, 4)
		
		


func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_HIDDEN



## 调试用放置物品
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("放置构筑物"):
		if _当前手上的蓝图实例!=null:
			var 实例 := _当前手上的蓝图实例.获取对应构筑物的实例化() # 根据蓝图实例化
			
			if 可放置建筑层.尝试在数据意义上将构筑物加入场景指定位置_Atom(实例, 当前鼠标图块坐标):
				print("成功放置")
				可放置建筑层.add_child(实例, true)
				实例.position = 实例.根据所在格子获取新的局部坐标(当前鼠标图块坐标, 图块大小)
			else:
				print("放置失败")
				实例.queue_free()
		else:
			print("手上没有蓝图.")
	
	elif event.is_action_pressed("移除构筑物"):
		var 可能存在的实例 := 可放置建筑层.获取占据指定位置的构筑物_Atom(当前鼠标图块坐标)
		if 可放置建筑层.尝试在数据意义上移除指定位置的构筑物_Atom(当前鼠标图块坐标):
			print("成功移除")
			可能存在的实例.queue_free()
		else:
			print("移除失败.")


func 设置当前手上的蓝图实例(蓝图实例:构筑物蓝图实例):
	if _当前手上的蓝图实例:
		_当前手上的蓝图实例.queue_free()
	
	_当前手上的蓝图实例 = 蓝图实例
	
	# 如果输入非null,则将实例化的场景塞到蓝图显示层里.
	if 蓝图实例:
		蓝图显示层.add_child(蓝图实例, true)


func _on_切换到_试作型投射物防御塔_pressed() -> void:
	设置当前手上的蓝图实例(资源管理器.蓝图预制件_机枪塔.instantiate())


func _on_切换到_试作型电弧防御塔_pressed() -> void:
	设置当前手上的蓝图实例(资源管理器.蓝图预制件_特斯拉塔.instantiate())


func _on_切换到_无蓝图_pressed() -> void:
	设置当前手上的蓝图实例(null)


func _on_切换到_建筑房子_pressed() -> void:
	设置当前手上的蓝图实例(资源管理器.蓝图预制件_测试房子.instantiate())
