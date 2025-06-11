extends JAM_实体
class_name JAM_基地


static var 基地单例:JAM_基地


static var 资源_木材 := 0
static var 资源_矿物 := 0

func _ready() -> void:
	基地单例 = self
