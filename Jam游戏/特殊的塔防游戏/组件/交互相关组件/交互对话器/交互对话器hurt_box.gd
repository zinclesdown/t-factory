class_name 交互对话器HurtBox实例
extends 交互HurtBox实例

## 预制的交互器. 如果玩家与其交互, 就会进入对话状态.


@export var 对话文件资源:DialogueResource

func _被Hitbox执行了交互(hitbox:交互HitBox实例, args:Array):
	被执行了交互.emit(hitbox, args)
	
	if 对话文件资源:
		print("由于交互对话器被交互, 对话组件被激活了!")
		对话组件.开始对话(hitbox.所有者实例, self.owner, 对话文件资源)
		process_mode = Node.PROCESS_MODE_DISABLED

		await 对话组件.对话结束
		await get_tree().create_timer(1).timeout
		process_mode = Node.PROCESS_MODE_INHERIT

		print("OK. Next?")
	else:
		push_error("没有找到对话资源!")
