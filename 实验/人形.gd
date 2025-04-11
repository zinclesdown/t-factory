extends CharacterBody2D
class_name 人形角色


@export var 控制器: 角色控制器
@export var 交互HitBox:交互HitBox实例



## 角色靠控制器来进行操作。控制器本质上就是AI.（对玩家而言是接受玩家输入的组件。）
func _physics_应用控制器(delta):
	if 控制器:
		控制器.physics_应用控制器(self, delta)
	else:
		push_error("未配置控制器！")



## 应用控制器。
func _physics_process(delta: float) -> void:
	_physics_应用控制器(delta)
