class_name 玩家角色控制器
extends 角色控制器


@export var 行走速度 := 200
@export var 跑步速度 := 360
@export var 跳跃速度 := 600

#@export var 交互HitBox:交互HitBox实例

func physics_应用控制器(chara:人形角色, _delta:float):
	_physics_默认方法_处理重力(chara)
	
	# 施加玩家控制
	var inputDir := Input.get_axis("左移", "右移")
	if Input.is_action_pressed("跑步"):
		chara.velocity.x = 跑步速度 * inputDir
	else:
		chara.velocity.x = 行走速度 * inputDir
	
	
	# 施加跳跃检测
	if Input.is_action_just_pressed("跳跃"):
		chara.velocity.y = -跳跃速度
	
	# 施加跳下平台检测
	if Input.is_action_pressed("跳下平台"): # 如果按下了跳下平台键(下键),则忽略所有向下的平台
		chara.set_collision_mask_value(2, false)
	else:
		chara.set_collision_mask_value(2, true)
	
	# 施加交互检测
	if Input.is_action_just_pressed("执行交互"):
		chara.交互HitBox.对最近的HurtBox进行交互()
		pass
	
	
	chara.move_and_slide()
