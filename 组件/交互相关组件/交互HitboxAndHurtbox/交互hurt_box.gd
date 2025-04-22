class_name 交互HurtBox实例
extends Area2D



signal 被执行了交互(hitbox:交互HitBox实例, args:Array)


func _被Hitbox执行了交互(hitbox:交互HitBox实例, args:Array):
	被执行了交互.emit(hitbox, args)
