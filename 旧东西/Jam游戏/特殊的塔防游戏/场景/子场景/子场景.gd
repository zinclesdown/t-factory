extends Node2D
class_name 子场景


## 子场景 存在于 主要场景 内.
## 子场景规定了"依赖".

## 子场景是容纳角色的容器,如果子场景被破坏,角色会被踢出子场景.

@export var 子场景名称 :String = "待命名子场景"

@export var 上级子场景 :子场景 ## 上一级.若该子场景被析构,则将所有角色踢出去.
@export var 上级子场景的角色默认初始化位置 := Vector2.ZERO ## 假设角色离开, 要把角色踢到哪里 ?

@export_category("可选建筑相关")

@export var 可放置建筑层: 可放置建筑层实例
@export var 蓝图显示层: Node2D



var 角色列表 :Array[人形角色] = [] ## 当前场景内所有角色.





# TEST
func 获取此子场景所在的主要场景() -> 主要场景:
	var curParent := get_parent()
	while curParent != null: # 尝试向上寻找
		if curParent is 主要场景:
			break
		else:
			curParent = curParent.get_parent()
	
	if curParent is 主要场景:
		return curParent
	else:
		push_error("错误:该子场景向上找不到任何主要场景!")
		return null



## 对子场景进行初始化. 不添加到场景树里. 
func 对属性进行初始化(该子场景的上级子场景:子场景) -> void:
	self.上级子场景 = 该子场景的上级子场景
	
