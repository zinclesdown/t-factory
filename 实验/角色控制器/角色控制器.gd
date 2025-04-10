class_name 角色控制器 extends Resource

## 控制角色的抽象基类。



## 应用控制器。默认仅处理重力。
#@virtual
func physics_应用控制器(chara:人形角色, delta:float):
	_physics_默认方法_处理重力(chara)
	chara.move_and_slide()



func _physics_默认方法_处理重力(chara:人形角色):
	if chara.is_on_floor():
		chara.velocity.y = 0
	else:
		chara.velocity += 全局.重力加速度
