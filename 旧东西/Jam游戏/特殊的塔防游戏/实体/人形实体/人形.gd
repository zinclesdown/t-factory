extends CharacterBody2D
class_name 人形角色



@export var 血量 :int= 100
@export var 最大血量 :int= 100

var 当前手持物品 : 可使用物品




## 初始化阶段, 要为角色设置所在场景.
func _ready() -> void:
	var parent := get_parent()
	
	while is_instance_valid(parent):
		# 检查Parent是否是子场景
		if parent is 子场景:
			parent.角色列表.append(self)
			# 如果找到了子场景, 初始化, 加入列表, 退出
			return
		else:
			parent = parent.get_parent()
			continue
	
	# 如果找不到
	push_error("错误:人形角色不在子场景内, 因此未能初始化子场景的角色列表!")




## TESTME
func 切换该角色所在子场景(新的子场景:子场景, 新的子场景内位置:Vector2) -> void:
	# 先移除索引
	获取此角色所在子场景().角色列表.erase(self)
	
	# 然后移除树
	if is_inside_tree():
		get_parent().remove_child(self)
	
	# 然后加入, 设置索引, 并设置自己的位置
	新的子场景.add_child(self)
	新的子场景.角色列表.append(self)
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



func 获取主要场景()->主要场景:
	var curParent := get_parent()
	while curParent != null: # 尝试向上寻找
		if curParent is 主要场景:
			break
		else:
			curParent = curParent.get_parent()
	if curParent is 主要场景:
		return curParent
	else:
		push_error("错误:角色向上找不到任何主要场景!")
		return null



## 受到攻击, 此函数应由攻击方调用.
func 受到攻击(伤害:int, 源头:攻击源) -> void:
	血量 -= 伤害
	血量 = clampi(血量, 0, 最大血量)
	
	print("受到源头为 %s 的 %s 点伤害!" % [源头, 伤害])
	
	if 血量 <= 0:
		血量耗尽死亡()


## 血量为0时的回调函数.
func 血量耗尽死亡() -> void:
	self.queue_free()
