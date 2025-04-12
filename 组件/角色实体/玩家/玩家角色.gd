extends 人形角色
class_name 玩家角色

@export var 行走速度 := 200
@export var 跑步速度 := 360
@export var 跳跃速度 := 600


@export var 交互HitBox:交互HitBox实例


var 当前手持物品 : 可使用物品





func _physics_process(_delta: float) -> void:
	# 处理重力
	if is_on_floor():
		velocity.y = 0
	else:
		velocity += 全局.重力加速度
	
	
	if 获取主要场景().是自由活动状态():
		_physics_自由控制(_delta)
	elif 获取主要场景().是交互中状态():
		_physics_交互中(_delta)
	elif 获取主要场景().是对话中状态():
		_physics_对话中(_delta)

func _physics_交互中(_delta:float):
	pass

func _physics_对话中(_delta:float):
	pass

func _physics_自由控制(_delta:float):
	# 施加玩家控制
	var inputDir := Input.get_axis("左移", "右移")
	if Input.is_action_pressed("跑步"):
		velocity.x = 跑步速度 * inputDir
	else:
		velocity.x = 行走速度 * inputDir
	
	# 施加跳跃检测
	if Input.is_action_just_pressed("跳跃"):
		velocity.y = -跳跃速度
	
	# 施加跳下平台检测
	if Input.is_action_pressed("跳下平台"): # 如果按下了跳下平台键(下键),则忽略所有向下的平台
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)
	
	# 施加交互检测
	if Input.is_action_just_pressed("执行交互"):
		交互HitBox.对最近的HurtBox进行交互()
		pass
	
	# 还会重设当前玩家的所在子场景.
	获取此角色所在子场景().获取此子场景所在的主要场景().当前玩家所在的子场景 = 获取此角色所在子场景()
	
	move_and_slide()
