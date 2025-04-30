class_name 组件_建筑物建造者
extends Node2D

@export var 构筑物蓝图显示层: Node2D  ## 蓝图显示. 蓝图会被作为子节点被放在这里.
@export var 构筑物放置层: 可放置建筑层实例  ## 构筑物会被放在该层内.
#@export var 世界图层组: Array[TileMapLayer]  ## 被占据场景由以下层组成.


#region migration temp
#@export var 可放置建筑层: 可放置建筑层实例 ## 建筑模块. 所有建筑物的父节点.
#@export var 蓝图显示层:Node2D ## 蓝图在这里显示.

@export var 图块大小 := Vector2i(32, 32)

var 当前鼠标图块坐标:Vector2i

var _当前手上的蓝图实例: 构筑物蓝图实例 ## 玩家手里拿着的蓝图. 即将用于部署.


#endregion


func 是否位于构筑物功能有效的场景内()->bool:
	if is_instance_valid(获取所在子场景().可放置建筑层) and is_instance_valid(获取所在子场景().蓝图显示层):
		if is_instance_valid(构筑物蓝图显示层) and is_instance_valid(构筑物放置层): # 得确保已经设置好了
			return true
	return false




func 获取所在子场景() -> 子场景:
	return (get_parent() as 人形角色).获取此角色所在子场景()


func _ready() -> void:
	assert(get_parent() is 人形角色, "错误: 该节点必须作为人形角色的直接子节点存在.")


func _process_刷新所在子世界相关信息():
	var 所在子场景 := (get_parent() as 人形角色).获取此角色所在子场景()
	
	# 如果在"有建筑相关功能的场景内", 则设置
	if 是否位于构筑物功能有效的场景内()==true:
		构筑物蓝图显示层 = 所在子场景.蓝图显示层
		构筑物放置层 = 所在子场景.可放置建筑层
	else:
		构筑物蓝图显示层 = null
		构筑物放置层 = null


func _process(_delta: float) -> void:
	self.global_position = Vector2.ZERO
	
	_process_刷新所在子世界相关信息()
	

	当前鼠标图块坐标 = Vector2i(
		floori(get_global_mouse_position().x / 图块大小.x), 
		floori(get_global_mouse_position().y / 图块大小.y)
	) 

	# 只有在所在场景有必要条件的情况下, 才会进行放置相关操作.
	if 是否位于构筑物功能有效的场景内()==true:

		#%构筑物表信息.text = ""
		#%构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._位置到构筑物的映射字典) + "\n"
		#%构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._构筑物根位置信息) + "\n"
		
		# 蓝图对齐鼠标
		构筑物蓝图显示层.position = 当前鼠标图块坐标*图块大小
	
	
	queue_redraw()


## 绘制 "放置框"
func _draw() -> void:
	if _当前手上的蓝图实例 and 是否位于构筑物功能有效的场景内():
		var 构筑物大小X := _当前手上的蓝图实例.构筑物大小.x
		var 构筑物大小Y := _当前手上的蓝图实例.构筑物大小.y
		
		var 颜色:Color
		if 构筑物放置层.是否可在位置放置构筑物实例_Atom(_当前手上的蓝图实例, 当前鼠标图块坐标):
			颜色 = Color.GREEN
		else:
			颜色 = Color.RED
		
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0          ,0          )), 图块大小*(当前鼠标图块坐标+Vector2i(0          ,构筑物大小Y)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0          ,构筑物大小Y)), 图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,构筑物大小Y)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,构筑物大小Y)), 图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,0          )), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(构筑物大小X,0          )), 图块大小*(当前鼠标图块坐标+Vector2i(0          ,0          )), 颜色, 2)
	
	elif 是否位于构筑物功能有效的场景内():
		var 颜色:Color = Color.WHITE
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,1)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,1)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,0)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,0)), 颜色, 2)

	else:
		var 颜色:Color = Color.DIM_GRAY
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,1)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,1)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,0)), 颜色, 2)
		draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,0)), 颜色, 2)



## 调试用放置物品
func _unhandled_input(event: InputEvent) -> void:
	
	# 处理"建筑"
	if 是否位于构筑物功能有效的场景内():
	
		if event.is_action_pressed("放置构筑物"):
			if _当前手上的蓝图实例!=null:
				var 实例 := _当前手上的蓝图实例.获取对应构筑物的实例化() # 根据蓝图实例化
				
				if 构筑物放置层.尝试在数据意义上将构筑物加入场景指定位置_Atom(实例, 当前鼠标图块坐标):
					print("成功放置")
					构筑物放置层.add_child(实例, true)
					实例.position = 实例.根据所在格子获取新的局部坐标(当前鼠标图块坐标, 图块大小)
				else:
					print("放置失败")
					实例.queue_free()
			else:
				print("手上没有蓝图.")
		
		elif event.is_action_pressed("移除构筑物"):
			var 可能存在的实例 := 构筑物放置层.获取占据指定位置的构筑物_Atom(当前鼠标图块坐标)
			if 构筑物放置层.尝试在数据意义上移除指定位置的构筑物_Atom(当前鼠标图块坐标):
				print("成功移除")
				可能存在的实例.queue_free()
			else:
				print("移除失败.")
	
	# 处理 "退出游戏"
	if event.is_action_pressed("退出游戏"):
		get_tree().quit()




func 设置当前手上的蓝图实例(蓝图实例:构筑物蓝图实例):
	if _当前手上的蓝图实例:
		_当前手上的蓝图实例.queue_free()
	
	_当前手上的蓝图实例 = 蓝图实例
	
	# 如果输入非null, 且所在子场景支持, 则将实例化的场景塞到蓝图显示层里.
	if 蓝图实例 and 是否位于构筑物功能有效的场景内():
		构筑物蓝图显示层.add_child(蓝图实例, true)


	
