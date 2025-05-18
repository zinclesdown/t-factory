class_name 交互HitBox实例
extends Area2D


var _当前重合的HurtBoxes :Array[交互HurtBox实例] = []

@export var 所有者实例 :人形角色 = owner


func _ready() -> void:
	if 所有者实例 == null:
		所有者实例 = owner

func 范围内有HurtBox() -> bool:
	if _当前重合的HurtBoxes.size() >= 1:
		return true
	else:
		return false



func 获取最近的交互HurtBox() -> 交互HurtBox实例:
	if 范围内有HurtBox():
		return _当前重合的HurtBoxes[0]
	else:
		return null



func 对最近的HurtBox进行交互(args:Array=[]) -> void:
	if 范围内有HurtBox():
		获取最近的交互HurtBox()._被Hitbox执行了交互(self, args)
	else:
		print("未能找到任何HurtBox")



func _physics_process(_delta: float) -> void:
	# HACK 每帧都进行判断,影响性能! 但是懒得改了
	var hurtBoxes := get_overlapping_areas()
	节点方法.对节点列表按距离进行升序排序(self, hurtBoxes)
	
	_当前重合的HurtBoxes = []
	_当前重合的HurtBoxes.assign(hurtBoxes)
	
