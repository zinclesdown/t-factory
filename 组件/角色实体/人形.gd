extends CharacterBody2D
class_name 人形角色


@export var 交互HitBox:交互HitBox实例

@export var 血量 := 100
@export var 最大血量 := 100


## TESTME
func 切换该角色所在子场景(新的子场景:子场景, 新的子场景内位置:Vector2):
	if is_inside_tree():
		get_parent().remove_child(self)
	
	新的子场景.add_child(self)
	self.position = 新的子场景内位置



func 获取此角色所在子场景()->子场景:
	var curParent := get_parent()
	
	while curParent != null: # 尝试向上寻找
		if curParent is 子场景:
			break
		else:
			curParent = curParent.get_parent()
	
	if curParent is 子场景:
		return curParent
	else:
		push_error("错误:角色向上找不到任何子场景!")
		return null


func 受到攻击(伤害, 攻击源):
	pass
