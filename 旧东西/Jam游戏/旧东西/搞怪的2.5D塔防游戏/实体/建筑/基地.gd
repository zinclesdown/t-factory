extends JAM_实体
class_name JAM_基地


static var 基地单例:JAM_基地


static var 资源_木材 := 0
static var 资源_矿物 := 0

func _ready() -> void:
	基地单例 = self


static func 获取单例位置() -> Vector3:
	return 基地单例.global_position

static func 获取单例水平位置() -> Vector2:
	return Vector2(基地单例.global_position.x, 基地单例.global_position.z)
