class_name UI单例
extends CanvasLayer

var 当前基地 :JAM_基地:
	get: return JAM_基地.基地单例

func _process(delta: float) -> void:
	ImGui.Begin("建筑系统")
	
	ImGui.SeparatorText("建筑")
	ImGui.Button("建造防御塔 10木材")
	ImGui.Button("建造民房(提供5人口) 5木材")
	
	ImGui.SeparatorText("人口")
	
	ImGui.Button("生产工人 10水晶")
	ImGui.Button("生产士兵 20水晶")
	ImGui.Button("生产弓箭手 50水晶")
	ImGui.Button("生产枪手 100水晶")
	ImGui.Button("生产法师 100水晶")
	
	ImGui.End()

	
