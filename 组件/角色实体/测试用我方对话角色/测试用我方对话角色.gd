extends 人形角色
class_name 测试用我方对话角色


@export var 对话文件资源 :DialogueResource
@export var 被玩家对话交互hurt_box: 交互HurtBox实例


func _physics_process(delta: float) -> void:
	# 处理重力
	if is_on_floor():
		velocity.y = 0
	else:
		velocity += 全局.重力加速度
	move_and_slide()



func _on_被玩家对话交互hurt_box_被执行了交互(hitbox: 交互HitBox实例, args: Array) -> void:
	print("尝试与荷取进行对话了!")
	对话组件.开始对话(hitbox.所有者实例, self, 对话文件资源)
	被玩家对话交互hurt_box.process_mode = Node.PROCESS_MODE_DISABLED

	await 对话组件.对话结束
	await get_tree().create_timer(1).timeout
	被玩家对话交互hurt_box.process_mode = Node.PROCESS_MODE_INHERIT

	print("OK. Next?")
