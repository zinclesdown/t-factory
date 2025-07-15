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
