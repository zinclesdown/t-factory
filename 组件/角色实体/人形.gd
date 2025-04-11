extends CharacterBody2D
class_name 人形角色


@export var 控制器: 角色控制器
@export var 交互HitBox:交互HitBox实例


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
		

## 角色靠控制器来进行操作。控制器本质上就是AI.（对玩家而言是接受玩家输入的组件。）
func _physics_应用控制器(delta):
	if 控制器:
		控制器.physics_应用控制器(self, delta)
	else:
		push_error("未配置控制器！")



## 应用控制器。
func _physics_process(delta: float) -> void:
	_physics_应用控制器(delta)
