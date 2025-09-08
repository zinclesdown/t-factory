extends JAM_实体
class_name JAM_敌人


@export var SPEED := 2.0

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# 追击玩家基地
	var 目的 := JAM_基地.获取单例位置()
	
	var dir := ((目的-self.global_position) * Vector3(1,0,1)).normalized()
	var dis := (目的-self.global_position).length()
	
	if dis > SPEED*delta:
		velocity = dir * SPEED
		move_and_slide()

	设置头文字("HP: %s" % [生命])


func 设置头文字(text:String)->void:
	$Label3D.text = text
