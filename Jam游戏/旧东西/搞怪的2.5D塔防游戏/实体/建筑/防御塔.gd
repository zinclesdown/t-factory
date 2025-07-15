extends JAM_实体
class_name JAM_防御塔


@export var 射箭攻击TSCN :PackedScene

@onready var 射击点marker: Marker3D = %射击点Marker
@onready var 射击冷却timer: Timer = $射击冷却Timer

@onready var 射击范围: Area3D = $射击范围



func _physics_process(delta: float) -> void:
	if 射击冷却timer.is_stopped():
		if is_instance_valid(获取范围内最近敌人()):
			射击冷却timer.start()
			进行射击(获取范围内最近敌人())


func 获取范围内敌人() -> Array:
	var arr := 射击范围.get_overlapping_bodies()
	arr.sort_custom(
		func(A:JAM_实体, B:JAM_实体) -> bool:
			var disA := (A.global_position - self.global_position).length()
			var disB := (B.global_position - self.global_position).length()
			return disA < disB
	)
	return arr


func 获取范围内最近敌人()->JAM_敌人:
	var arr := 获取范围内敌人()
	if arr.size() >= 1:
		return arr[0]
	return
 



func 进行射击(目标:JAM_实体) -> void:
	var 射击 := 射箭攻击TSCN.instantiate() as JAM_箭塔射击
	
	add_sibling(射击)
	射击.向目标单位射击(射击点marker.global_position, 目标)
	
