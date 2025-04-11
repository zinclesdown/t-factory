@tool
extends 构筑物场景实例


@export var 房子的子场景预制件:PackedScene
var 房子的子场景:子场景


## 此时执行传送操作
func _on_进入门的交互hurt_box_被执行了交互(hitbox: 交互HitBox实例, args: Array) -> void:
	print("执行传送操作!",hitbox, args)
	
	获取此构筑物所在的主要场景().将角色切换到子场景(hitbox.所有者实例, 房子的子场景, Vector2(1, 1))


## 当测试房子进入时, 初始化子场景信息.
func _ready() -> void:
	var 房子所在的子场景 := 获取此构筑物所在的子场景()
	var subScene :子场景 = 房子的子场景预制件.instantiate() as 子场景
	
	subScene.对属性进行初始化(房子所在的子场景)
	获取此构筑物所在的主要场景().添加子场景(subScene)
	房子的子场景 = subScene
	
	if not $"角色退出的位置".is_node_ready():
		await $"角色退出的位置".ready
	房子的子场景.上级子场景的角色默认初始化位置 = $"角色退出的位置".global_position



## 被移除时, 析构该房子的子场景预制件.
func _exit_tree() -> void:
	获取此构筑物所在的主要场景().移除并破坏子场景(房子的子场景)
