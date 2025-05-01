extends 攻击源



@export var 攻击范围Area2D:Area2D
@export var 攻击CD计时器:Timer

@export var 电击伤害 := 20

@export var 电弧特效实例_预制件 :PackedScene

var 当前攻击目标:人形角色 = null


func _physics_process(delta: float) -> void:
	# 获取靠近的单位表\ 最后读取最近的敌人单位
	var bodies := 攻击范围Area2D.get_overlapping_bodies()
	var 敌人Bodies := 节点方法.获取保留列表中组内节点的数组("敌人角色", bodies)
	节点方法.对节点列表按距离进行升序排序(self, 敌人Bodies)
	if 敌人Bodies.size() >= 1:
		当前攻击目标 = 敌人Bodies[0]
	else:
		当前攻击目标 = null
	
	# 假设CD满了,则攻击
	if 攻击CD计时器.is_stopped() and 当前攻击目标 != null:
		执行攻击(当前攻击目标)
		攻击CD计时器.start()


func 执行攻击(目标:人形角色):
	目标.受到攻击(电击伤害, self)
	
	var 电弧特效实例 :一次性电弧特效实例 = 电弧特效实例_预制件.instantiate()
	
	攻击源所有者.add_sibling(电弧特效实例)
	电弧特效实例.初始化特效(self.global_position, 目标.global_position)
