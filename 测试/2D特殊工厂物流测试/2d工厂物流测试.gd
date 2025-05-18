extends Node2D
## 2D工厂物流系统.

## 1. 定义工厂   Producer
## 2. 定义连接器 Connector
## 3. 进行寻路   Path Finder
## 4. 进行帧Tick Tick

## NOTE 最后记得把IMGUI进行特殊化.

var _IMGUI_显示DEMO面板 := [false]
var _IMGUI_显示调试面板 := [true]


## 有 "连接器"  "生产器" 两种节点.
##

class 生产器:
	pass

class 连接器:
	pass


func _process(delta: float) -> void:
	_IMGUI()
	queue_redraw()

func _IMGUI() -> void:
	# 主菜单
	if ImGui.BeginMainMenuBar():
		if ImGui.BeginMenu("调试"):
			if ImGui.MenuItem("打卡物流面板"):
				_IMGUI_显示调试面板[0] = !_IMGUI_显示调试面板[0]
			ImGui.EndMenu()
		if ImGui.BeginMenu("帮助"):
			if ImGui.MenuItem("打开Demo"):
				_IMGUI_显示DEMO面板[0] = !_IMGUI_显示DEMO面板[0]
			ImGui.EndMenu()
		ImGui.EndMainMenuBar()

	# 物流系统面板
	if _IMGUI_显示调试面板[0]:
		ImGui.Begin("物流系统测试", _IMGUI_显示调试面板, ImGui.WindowFlags_MenuBar)
		
		if ImGui.BeginTable("Table", 3):
			ImGui.TableNextRow()
			ImGui.TableNextColumn()
			ImGui.Text("Cell 1")
			ImGui.TableNextColumn()
			ImGui.Text("Cell 2")
			ImGui.EndTable()
		ImGui.End()
		
	# 可选的 Demo 窗口
	if _IMGUI_显示DEMO面板[0]:
		ImGui.ShowDemoWindow(_IMGUI_显示DEMO面板)

func 添加生产器(pos:Vector2, 生产器类型:Enum生产器类型)->void:
	print("试图在%s放置%s了!" % [str(pos), str(生产器类型)])

func 添加连接器(pos:Vector2, connector:连接器)->void:
	pass

#func 更新寻路()->void:
	#pass

const 网格大小 := Vector2(32,32)

func Tick()->void:
	pass

var 当前物品 := Enum物品.生产器

enum Enum物品 {
	生产器,
	连接器
}

enum Enum生产器类型 {
	风力发电机,
}

func 获取吸附网格中心后的点(pos:Vector2) -> Vector2:
	var 原点位置 :Vector2= floor(pos / 网格大小) * 网格大小
	return 原点位置 + 网格大小/2

func _draw() -> void:
	# 绘制红色框框
	draw_rect(Rect2(获取吸附网格中心后的点(get_global_mouse_position())-网格大小/2.0, 网格大小), Color.RED, false)
	draw_string(全局.全局字体, get_global_mouse_position(), str(get_global_mouse_position()))

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var 吸附后鼠标位置 := 获取吸附网格中心后的点(get_global_mouse_position())
		
		if 当前物品 == Enum物品.生产器:
			添加生产器(吸附后鼠标位置, Enum生产器类型.风力发电机)


func _ready() -> void:
	pass
	
