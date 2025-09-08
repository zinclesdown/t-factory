extends 人形角色
class_name 飞行远程攻击敌人角色



var _目标移动地点 :Vector2

@export var 导航Agent:NavigationAgent2D

@export var 随机移动范围半径 := 300 ## 随机选取距离100以内的某个地方 (显然不是随机)

@export var 移动速度 := 200 

@export var 抵达容忍范围 := 20 ## 100pixel以内则认为抵达了目的地, 避免抖动

## 在physics process里, 扫描周围的其他角色
func _physics_process(_delta: float) -> void:
	
	var distance := (导航Agent.get_next_path_position() - self.global_position).length()
	var dir := (导航Agent.get_next_path_position() - self.global_position).normalized()
	if distance >= 抵达容忍范围:
		velocity = dir * 移动速度
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	#print(velocity, _目标移动地点)


func _ready() -> void:
	_目标移动地点 = self.global_position


func _on_选取随机漫步位置的timer_timeout() -> void:
	
	var 弧度 := randf_range(0, 2*PI)
	var 半径 := randf_range(0, 随机移动范围半径)
	
	# 随机选取目的地
	_目标移动地点 = Vector2.from_angle(弧度) * 半径 + self.global_position
	导航Agent.target_position = _目标移动地点
	导航Agent.get_next_path_position()
