extends Path3D
class_name JAM_箭塔射击

@export var 开始点 :Vector3
#@export var 无追踪目标点:Vector3
@export var 追踪目标单位:JAM_实体

#@export var 启用追踪:bool= true

@onready var 箭矢: PathFollow3D = $箭矢

@export var 命中所耗时间 := 0.5

@export var 伤害 := 20

var 已经激活 := false

func 射击() -> void:
	if 已经激活 == false:
		已经激活 = true
		
		箭矢.progress_ratio = 0.0
		
		var tween := create_tween()
		tween.tween_property(箭矢, "progress_ratio", 1.0, 命中所耗时间)
		tween.tween_callback(
			func() -> void:
				if is_instance_valid(追踪目标单位):
					追踪目标单位.被命中({"伤害": 伤害})
		)
		tween.tween_callback(queue_free)


func 向目标单位射击(起始点:Vector3, 目标单位:JAM_实体) -> void:
	开始点 = 起始点
	追踪目标单位 = 目标单位
	
	射击()

func _physics_process(delta: float) -> void:
	if is_instance_valid(追踪目标单位):
		curve.set_point_position(0, 开始点)
		curve.set_point_position(1, 追踪目标单位.global_position)
