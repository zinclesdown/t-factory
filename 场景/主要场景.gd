extends Node
class_name 主要场景

## 主要的场景管理器.
## "主要场景" 是负责管理其他场景的 "容器", 他本身并没有场景.
## 任何子场景会被添加到容器内.


var _子场景表: Array[子场景] = []

var _子场景对应容器 :Dictionary = {}
#var _子场景对应容器 :Dictionary[子场景, SubViewportContainer] = {}

@export var 子场景所在根节点: Node
#@export var 调试初始化子场景组: Node # 位于该表内的场景,都会在初始化时,被追加到子场景中.


## 玩家所在位置. 负责hide其他场景, 仅show当前场景. 玩家角色的控制器会负责修改这一属性.
var 当前玩家所在的子场景:子场景 = null




func _ready() -> void:
	_ready_处理场景内已有子场景的初始化()
	_ready_处理玩家对话开始结束的操作状态切换()



func _ready_处理场景内已有子场景的初始化():
	# 先对子场景进行初始化. 假设我们预先定义了已有的子场景:
	for container:SubViewportContainer in 子场景所在根节点.get_children():
		# 移除不合法容器
		if (container.get_child_count() == 0) or (container.get_child(0) is not SubViewport):
			print("初始化的子场景容器 %s 不合法,移除..." % [container])
			container.queue_free()
			continue
		
		# 保留合法容器. 进行操作
		var subViewport :SubViewport= container.get_child(0)
		if (subViewport.get_child_count() == 0) or (subViewport.get_child(0) is not 子场景):
			print("初始化的子场景容器 %s 不合法,移除..." % [container])
			container.queue_free()
			continue
		
		var 待初始化子场景 :子场景 = subViewport.get_child(0) as 子场景
		_子场景表.append(待初始化子场景)
		_子场景对应容器[待初始化子场景] = container
		print("初始化了合法的容器: ", 待初始化子场景, "  容器:", container)



func _ready_处理玩家对话开始结束的操作状态切换():
	# 处理对话相关状态
	对话组件.对话开始.connect(
		func():
			
			玩家全局状态.操作状态设置为交互中()
	)
	对话组件.对话结束.connect(
		func():
			玩家全局状态.操作状态设置为自由活动()
	)
	pass




func _process(delta: float) -> void:
	%"显示子场景表".text = str(_子场景表)

	## 仅显示玩家所在的子场景
	for i:子场景 in _子场景对应容器:
		if 当前玩家所在的子场景 != i:
			_子场景对应容器[i].hide()
		else:
			_子场景对应容器[i].show()

## 追加子场景
func 添加子场景(追加的子场景:子场景):
	
	# 场景树里加东西.
	var 子视图容器 := SubViewportContainer.new()
	var 子视图 := SubViewport.new()
	
	子视图容器.stretch = true
	子视图容器.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	子视图容器.add_child(子视图)
	子视图容器.name = 追加的子场景.name
	子视图.add_child(追加的子场景)

	# Nearest, 方便像素渲染
	子视图.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST


	## 添加表记录.
	_子场景表.append(追加的子场景)
	_子场景对应容器[追加的子场景] = 子视图容器
	
	子场景所在根节点.add_child(子视图容器)
	print("追加了子场景, 并添加到场景树里了!!")



## 移除子场景, 会对子场景进行析构.
func 移除并破坏子场景(待移除子场景:子场景):
	var 容器 :SubViewportContainer= _子场景对应容器[待移除子场景]
	
	_子场景对应容器.erase(待移除子场景)
	_子场景表.erase(待移除子场景)
	
	容器.queue_free()
	print("主场景:: 移除并破坏了一个子场景! ", 待移除子场景)



## 把角色从场景A移动到场景B
func 将角色切换到子场景(角色:人形角色, 目标子场景:子场景, 默认位置:Vector2):
	print("试图将角色 %s 从原本场景 %s 移动到子场景 %s 的位置 %s 了!!" % [角色, 角色.获取此角色所在子场景(), 目标子场景, 默认位置])
	角色.切换该角色所在子场景(目标子场景, 默认位置)
	print("切换完毕.")

	# FIXME 有些地方没处理!
