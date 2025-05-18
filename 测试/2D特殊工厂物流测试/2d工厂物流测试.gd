extends Node2D
## 2D工厂物流系统.

## 1. 定义节点   Node
## 2. 定义连接器 Connector
## 3. 进行寻路   Path Finder
## 4. 进行帧Tick Tick

## NOTE 最后记得把IMGUI进行特殊化.

var _IMGUI_SHOW_DEMO_WINDOW := [false]
var _IMGUI_SHOW_LOGISTIC_DEBUG_WINDOW := [true]

func _ready() -> void:
	ImGuiGD.Connect(_IMGUI)

func _IMGUI()->void:
	# 主菜单
	if ImGui.BeginMainMenuBar():
		if ImGui.BeginMenu("调试"):
			if ImGui.MenuItem("打卡物流面板"):
				_IMGUI_SHOW_LOGISTIC_DEBUG_WINDOW[0] = !_IMGUI_SHOW_LOGISTIC_DEBUG_WINDOW[0]
			ImGui.EndMenu()
		if ImGui.BeginMenu("帮助"):
			if ImGui.MenuItem("打开Demo"):
				_IMGUI_SHOW_DEMO_WINDOW[0] = !_IMGUI_SHOW_DEMO_WINDOW[0]
			ImGui.EndMenu()
		ImGui.EndMainMenuBar()

	# 物流系统面板
	if _IMGUI_SHOW_LOGISTIC_DEBUG_WINDOW[0]:
		ImGui.Begin("物流系统测试", _IMGUI_SHOW_LOGISTIC_DEBUG_WINDOW, ImGui.WindowFlags_MenuBar)
		
		if ImGui.BeginTable("Table", 3):
			ImGui.TableNextRow()
			ImGui.TableNextColumn()
			ImGui.Text("Cell 1")
			ImGui.TableNextColumn()
			ImGui.Text("Cell 2")
			ImGui.EndTable()
		ImGui.End()
		
	# 可选的 Demo 窗口
	if _IMGUI_SHOW_DEMO_WINDOW[0]:
		ImGui.ShowDemoWindow(_IMGUI_SHOW_DEMO_WINDOW)

func 添加节点()->void:
	pass

func 添加连接器()->void:
	pass

func 更新寻路()->void:
	pass

func Tick()->void:
	pass
