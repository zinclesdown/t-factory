class_name JAM_资源 extends JAM_实体

@export var DEBUG_显示资源量 := false

@export var 资源 :Dictionary[String, int] = {
	"矿物": 500,
	"木材": 500
}

@export var 资源量显示Label :Label3D

func 采集资源(容量:int) -> Dictionary[String, int]:
	if 有剩余资源():
		# 清理
		for key in 资源:
			if 资源[key] <= 0:
				资源.erase(key)
		for key in 资源:
			var 实际采集资源量 := clampi(容量, 0, 获取资源量(key))
			资源[key] -= 实际采集资源量
			return {key:clampi(容量, 0, 资源[key])}
	return {}


func 获取资源量(资源名称:String)->int:
	return 资源.get(资源名称, 0)


func 有剩余资源() -> bool:
	if 资源.is_empty():
		return false
	for key:String in 资源:
		if 资源[key] <= 0:
			资源.erase(key)
	if 资源.is_empty():
		return false
	return true

func _process(_delta: float) -> void:
	super._process(_delta)
	
	if is_instance_valid(资源量显示Label) and DEBUG_显示资源量:
		资源量显示Label.text = str(资源)
	elif DEBUG_显示资源量==false:
		资源量显示Label.text = ""
		
	
	for key in 资源:
		if 资源[key] <=0:
			资源.erase(key)
	
	if not 有剩余资源():
		queue_free()
