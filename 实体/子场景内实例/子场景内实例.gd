class_name 子场景内的实例
extends Node2D

## 子场景内的东西, 统称为子场景内的实例.


func 获取此实例所在的子场景() -> 子场景:
	var curParent := get_parent()
	while curParent != null: # 尝试向上寻找
		if curParent is 子场景:
			break
		else:
			curParent = curParent.get_parent()
	
	if curParent is 子场景:
		return curParent
	else:
		push_error("错误:向上找不到任何子场景!")
		return null



func 获取此实例所在的主要场景() -> 主要场景:
	var curParent := get_parent()
	while curParent != null: # 尝试向上寻找
		if curParent is 主要场景:
			break
		else:
			curParent = curParent.get_parent()
	
	if curParent is 主要场景:
		return curParent
	else:
		push_error("错误:向上找不到任何主要场景!")
		return null
