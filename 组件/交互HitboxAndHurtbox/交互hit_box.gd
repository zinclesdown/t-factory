class_name 交互HitBox实例
extends Area2D


var _当前重合的HurtBoxes :Array[交互HurtBox实例] = []



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



func 对最近的HurtBox进行交互(args:Array=[]):
	if 范围内有HurtBox():
		获取最近的交互HurtBox()._被Hitbox执行了交互(self, args)
	else:
		print("未能找到任何HurtBox")



func _physics_process(_delta: float) -> void:
	# HACK 每帧都进行判断,影响性能! 但是懒得改了
	var hurtBoxes := get_overlapping_areas()
	hurtBoxes.sort_custom( # 按距离排序. 我们优先选择最近的
		func(A:Node2D, B:Node2D):
			var disA := (self.global_position - A.global_position).length()
			var disB := (self.global_position - B.global_position).length()
			if disA < disB:
				return true
			else:
				return false
	)
	_当前重合的HurtBoxes = []
	_当前重合的HurtBoxes.assign(hurtBoxes)
	
