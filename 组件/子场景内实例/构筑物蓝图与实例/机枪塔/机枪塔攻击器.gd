class_name 机枪塔攻击源
extends 攻击源

@export var 索敌区域: Area2D
@export var 子弹生成处: Marker2D


func _physics_process(delta: float) -> void:
	var bodies := 索敌区域.get_overlapping_bodies()
	# TODO 实现机枪塔 索敌\攻击 逻辑
