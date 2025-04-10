class_name 玩家角色控制器
extends 角色控制器


@export var 行走速度 := 200
@export var 跑步速度 := 360
@export var 跳跃速度 := 300


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
	
	chara.move_and_slide()
