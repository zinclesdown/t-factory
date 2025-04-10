@tool
class_name 构筑物场景实例
extends Node2D


# 大小为32*32的格子。
@export var 构筑物大小 := Vector2i(1,1):
	set(n):
		if not is_node_ready(): await ready
		构筑物大小 = n
		构筑物范围矩形.size = n*32


@export var 构筑物范围矩形 :ReferenceRect
