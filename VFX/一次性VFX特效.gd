class_name 一次性VFX特效实例
extends Marker2D
## 一次性的VFX特效都会在存在时间结束后被释放.


@export var 存在时间 := 0.5

func _ready() -> void:
	get_tree().create_timer(存在时间).timeout.connect(
		func():
			queue_free()
	)
