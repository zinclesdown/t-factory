@tool
class_name 构筑物蓝图实例
extends 构筑物场景实例


@export var 对应的构筑物预制件:PackedScene

## 蓝图 继承自 原构筑物.


func 获取对应构筑物的实例化() -> 构筑物场景实例:
	return 对应的构筑物预制件.instantiate() as 构筑物场景实例
