@tool
extends 构筑物场景实例


@export var 房子的子场景预制件:PackedScene
var 房子的子场景:子场景




## 当测试房子进入时, 初始化子场景信息.
func _ready() -> void:
	var 房子所在的子场景 := 获取此实例所在的子场景()
	var subScene :子场景 = 房子的子场景预制件.instantiate() as 子场景
	
	subScene.对属性进行初始化(房子所在的子场景)
	获取此实例所在的主要场景().添加子场景(subScene)
	房子的子场景 = subScene
	
	%"交互式子场景连接门".初始化连接门(subScene.出口连接门)
	
	
	if not $"角色退出的位置".is_node_ready():
		await $"角色退出的位置".ready
	房子的子场景.上级子场景的角色默认初始化位置 = $"角色退出的位置".global_position



## 被移除时, 析构该房子的子场景预制件.
func _exit_tree() -> void:
	获取此实例所在的主要场景().移除并破坏子场景(房子的子场景)
