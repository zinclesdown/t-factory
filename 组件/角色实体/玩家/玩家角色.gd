extends 人形角色
class_name 玩家角色

@export var 行走速度 := 200
@export var 跑步速度 := 360
@export var 跳跃速度 := 600


@export var 交互HitBox:交互HitBox实例


@export var 建筑物建造者组件: 组件_建筑物建造者



func _process(delta: float) -> void:
	玩家全局状态.设置当前玩家角色(self)

func _physics_process(_delta: float) -> void:
	# 处理重力
	if is_on_floor():
		velocity.y = 0
	else:
		velocity += 全局.重力加速度
	
	if 玩家全局状态.是自由活动状态():
		_physics_自由控制(_delta)
	elif 玩家全局状态.是交互中状态():
		_physics_交互中(_delta)
	elif 玩家全局状态.是对话中状态():
		_physics_对话中(_delta)
	
	# 处理交互HurtBox, 标记箭头
	var 最近的交互hurtbox := 交互HitBox.获取最近的交互HurtBox()
	if 最近的交互hurtbox:
		%"UI_交互指示器".show()
		%"UI_交互指示器".global_position = 最近的交互hurtbox.global_position
	else:
		%"UI_交互指示器".hide()


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
