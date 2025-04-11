@tool
class_name 构筑物场景实例
extends Node2D

### 在场景内的构筑物所在位置。

# 大小为32*32的格子。
@export var 构筑物大小 := Vector2i(1, 1):
	set(n):
		构筑物大小 = n
		
		if not is_node_ready(): await ready
		构筑物范围矩形.size = n*32


@export var 构筑物范围矩形 :ReferenceRect


func 获取本地占据的空间格子() -> Array[Vector2i]:
	var 本地Coord :Array[Vector2i] = []
	for i in 构筑物大小.x:
		for j in 构筑物大小.y:
			本地Coord.append(Vector2i(i, j))
	return 本地Coord


func 获取全局占据的空间格子(当前构筑物的全局位置:Vector2i) -> Array[Vector2i]:
	var 本地Coord :Array[Vector2i] = []
	for i in 构筑物大小.x:
		for j in 构筑物大小.y:
			本地Coord.append(Vector2i(i, j) + 当前构筑物的全局位置)
	#print(本地Coord)
	return 本地Coord



func 获取此构筑物所在的子场景() -> 子场景:
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



func 获取此构筑物所在的主要场景() -> 主要场景:
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



## 如果构筑物在 (1,2), 格子大小为 (16, 16), 那么,该函数将返回(16, 32)
## 控制构筑物位置的函数应该位于上层. 该函数只用于负责协助定位. 
func 根据所在格子获取新的局部坐标(当前格子位置:Vector2i, 图块大小:Vector2i) -> Vector2:
	return Vector2(当前格子位置 * 图块大小)


## 方便调试.打印的信息.
func _to_string() -> String:
	return "<%s  [%s]>" % [self.name, hash(self)%10000]
