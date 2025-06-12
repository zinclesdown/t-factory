extends JAM_实体
class_name JAM_人


@onready var 目标位置 :Vector3 = self.global_position
var 目标矿点 :JAM_资源
@export var 移动速度 := 3.0

@onready var 状态图: StateChart = $人物状态
@onready var 采矿范围: Area3D = $采矿范围

@export var 携带资源名称 :String = ""
@export var 携带资源量 :int = 0
@export var 最大资源携带量 :int = 5


func 命令移动(_目标位置:Vector3) -> void:
	目标位置 = _目标位置
	状态图.send_event("采集结束")


func 命令采矿(矿:JAM_资源) -> void:
	目标矿点 = 矿
	状态图.send_event("采集资源")


func 设置头文字(text:String)->void:
	$Label3D.text = text


func _on_采集资源_state_processing(_delta: float) -> void:
	#设置头文字("采集资源")
	var 基地单例 := JAM_基地.基地单例
	if is_instance_valid(目标矿点)==false or 目标矿点.有剩余资源()==false: # 防止已经挖完了
		状态图.send_event("采集结束")
		设置头文字("采集结束了")
		return
	
	# 如果 目标矿点没有抵达，且手里没有资源，则尝试移动到资源点。
	elif 携带资源量 <= 0 and not (目标矿点 in 采矿范围.get_overlapping_bodies()):
		var dir := (目标矿点.global_position - global_position)
		var dir_norm := dir.normalized()
		velocity = dir_norm * 移动速度
		velocity.y = 0
		move_and_slide()
		设置头文字("前往资源点")

	# 检查是否重叠。重叠则进入采掘范围。
	elif 目标矿点 in 采矿范围.get_overlapping_bodies() and 身上还有剩余空间()==true:
		# 有空间，则采集
		var 采集到的资源 :Dictionary[String, int] = 目标矿点.采集资源(最大资源携带量)
		var 资源名称 :String = 采集到的资源.keys()[0]
		var 资源量 := 采集到的资源[资源名称]
		
		携带资源名称 = 资源名称
		携带资源量 = 资源量
		设置头文字("进行采集")
		

	# 无剩余空间，则返回
	elif 身上还有剩余空间()==false and is_instance_valid(基地单例) and not (基地单例 in 采矿范围.get_overlapping_bodies()):
		var dir_norm := (基地单例.global_position - global_position).normalized()
		velocity = dir_norm * 移动速度
		velocity.y = 0
		
		move_and_slide()
		设置头文字("采集完毕返回基地")
	
	# 带着资源回到基地了。
	elif 身上还有剩余空间()==false and is_instance_valid(基地单例) and (基地单例 in 采矿范围.get_overlapping_bodies()):
		if 携带资源名称 == "矿物":
			JAM_基地.资源_矿物 += 携带资源量
		elif 携带资源名称 == "木材":
			JAM_基地.资源_木材 += 携带资源量
		携带资源名称 = ""
		携带资源量 = 0
		设置头文字("资源回收完毕。")
	else:
		设置头文字("错误")





func _on_自由活动_state_processing(delta: float) -> void:
	设置头文字("自由活动")
	
	var distance := 目标位置 - global_position
	var dir_norm := distance.normalized()
	
	velocity = dir_norm * 移动速度
	velocity.y = 0
	
	if distance.length() >= velocity.length()*delta:
		move_and_slide()


func 身上还有剩余空间() -> bool:
	return 携带资源量 == 0
