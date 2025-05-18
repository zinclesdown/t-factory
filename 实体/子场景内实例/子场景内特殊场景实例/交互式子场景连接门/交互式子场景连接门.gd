class_name 交互式子场景连接门
extends 特殊物品场景实例


@export var 目标门:交互式子场景连接门


func 初始化连接门(目标连接门:交互式子场景连接门) -> void:
	self.目标门 = 目标连接门
	if 目标连接门.目标门 != self:
		目标连接门.目标门 = self
	print("将门连接了.")


func 被单位执行交互了(交互者:人形角色) -> void:
	print("交互式子场景连接门::将交互者送至目标门处...")
	
	# 把交互者放到目标门那里
	交互者.切换该角色所在子场景(目标门.获取此实例所在的子场景(), 目标门.global_position)


func _on_交互hurt_box_被执行了交互(hitbox: 交互HitBox实例, _args: Array) -> void:
	被单位执行交互了(hitbox.所有者实例)
