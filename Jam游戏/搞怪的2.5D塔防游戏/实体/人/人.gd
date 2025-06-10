extends JAM_实体
class_name JAM_人


@onready var 目标位置 :Vector3 = self.global_position
@export var 移动速度 := 3.0


func 命令移动(_目标位置:Vector3) -> void:
	目标位置 = _目标位置


func _physics_process(_delta: float) -> void:
	# 会舍弃y轴。
	var dir := (目标位置 - global_position)
	var dir_norm := dir.normalized()
	
	velocity = dir_norm * 移动速度
	velocity.y = 0
	
	move_and_slide()
