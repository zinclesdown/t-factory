extends Node2D

@export var 特斯拉塔构筑物:PackedScene
@export var 机枪塔构筑物:PackedScene


@export var 可放置建筑层: 可放置建筑层实例



var 当前鼠标图块坐标:Vector2i

var 图块大小 := Vector2i(32, 32)



func _process(_delta: float) -> void:
	当前鼠标图块坐标 = Vector2i(
		floori(get_global_mouse_position().x / 图块大小.x), 
		floori(get_global_mouse_position().y / 图块大小.y)
	) 
	
	%鼠标Label.text = '当前图块' + str(当前鼠标图块坐标)
	%"鼠标跟随".global_position = %"鼠标跟随".get_global_mouse_position()
	
	queue_redraw()

## 绘制 "放置框"
func _draw() -> void:
	draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,1)), Color.RED)
	draw_line(图块大小*(当前鼠标图块坐标+Vector2i(0,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,1)), Color.RED)
	draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,1)), 图块大小*(当前鼠标图块坐标+Vector2i(1,0)), Color.RED)
	draw_line(图块大小*(当前鼠标图块坐标+Vector2i(1,0)), 图块大小*(当前鼠标图块坐标+Vector2i(0,0)), Color.RED)


func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_HIDDEN


## 调试用放置物品
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("放置构筑物"):
		var 实例 := 特斯拉塔构筑物.instantiate() as 构筑物场景实例
		
		if 可放置建筑层.尝试在数据意义上将构筑物加入场景指定位置_Atom(实例, 当前鼠标图块坐标):
			print("成功放置")
			可放置建筑层.add_child(实例, true)
			实例.position = 实例.根据所在格子获取新的局部坐标(当前鼠标图块坐标, 图块大小)
		else:
			print("放置失败")
			实例.queue_free()
	
	elif event.is_action_pressed("移除构筑物"):
		var 可能存在的实例 := 可放置建筑层.获取占据指定位置的构筑物_Atom(当前鼠标图块坐标)
		if 可放置建筑层.尝试在数据意义上移除指定位置的构筑物_Atom(当前鼠标图块坐标):
			print("成功移除")
			可能存在的实例.queue_free()
		else:
			print("移除失败.")
