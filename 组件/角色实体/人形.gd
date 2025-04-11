extends CharacterBody2D
class_name 人形角色



@export var 血量 :int= 100
@export var 最大血量 :int= 100


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




## 受到攻击, 此函数应由攻击方调用.
func 受到攻击(伤害:int, 源头:攻击源):
	血量 -= 伤害
	血量 = clampi(血量, 0, 最大血量)
	
	print("受到源头为 %s 的 %s 点伤害!" % [源头, 伤害])
	
	if 血量 <= 0:
		血量耗尽死亡()


## 血量为0时的回调函数.
func 血量耗尽死亡():
	self.queue_free()
