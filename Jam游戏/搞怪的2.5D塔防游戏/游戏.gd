extends Node3D

@export var 人_TSCN :PackedScene
@export var 防御塔_TSCN: PackedScene
@export var 蓝图_防御塔_TSCN: PackedScene


@onready var 组_人物: Node3D = $世界/组_人物

@onready var 组_资源: Node3D = $世界/组_资源

@onready var 组_建筑物: Node3D = $世界/组_建筑物
@onready var 组_建筑物_蓝图预览: Node3D = $世界/组_建筑物_蓝图预览

@onready var 组_其他: Node3D = $世界/组_其他



var 当前模式 := 自由模式 
var 当前蓝图建筑名称 := ""
enum {
	自由模式,
	建造模式,
}


func _process(_delta: float) -> void:
	ImGui.Begin("生产")
	if ImGui.Button("造人"):
		造人()
	
	ImGui.Text("当前蓝图建筑名称: " + 当前蓝图建筑名称)
	ImGui.Text("当前模式: %s" % 当前模式)
	
	if ImGui.Button("造防御塔"):
		当前蓝图建筑名称 = "防御塔"
		当前模式 = 建造模式
	ImGui.End()

	if 当前蓝图建筑名称 == "防御塔":
		预览防御塔(JAM_玩家.获取鼠标与3d选择面相交位置())
	else:
		组_建筑物_蓝图预览.get_children().all(func(a:Node)->bool: a.queue_free(); return true)


func _unhandled_input(_event: InputEvent) -> void:
	var 鼠标3D位置 := JAM_玩家.获取鼠标与3d选择面相交位置()
	
	if Input.is_action_just_pressed("鼠标右键"):
		当前蓝图建筑名称 = ""
		当前模式 = 自由模式
	
	if Input.is_action_just_pressed("鼠标左键"):
		if 当前模式 == 建造模式 and 当前蓝图建筑名称 == "防御塔":
			造防御塔(鼠标3D位置)


func 造防御塔(位置:Vector3) -> void:
	var 实例 :JAM_防御塔= 防御塔_TSCN.instantiate()
	组_建筑物.add_child(实例)
	实例.global_position = 位置


func 预览防御塔(位置:Vector3) -> void:
	组_建筑物_蓝图预览.global_position = 位置
	
	if 组_建筑物_蓝图预览.has_node("防御塔_蓝图"):
		pass
	else:
		组_建筑物_蓝图预览.get_children().all(func(a:Node)->bool: a.queue_free(); return true)
		var child := 蓝图_防御塔_TSCN.instantiate()
		child.name = "防御塔_蓝图"
		组_建筑物_蓝图预览.add_child(child,)



func 造人() -> void:
	var 实例 :JAM_人 = 人_TSCN.instantiate()
	组_人物.add_child(实例)
	
	实例.global_position = JAM_基地.获取单例位置()
	实例.global_position.y = 0
	实例.命令移动(JAM_基地.获取单例位置() + Vector3(randf_range(-1, 1), 0, randf_range(1, 2)))
