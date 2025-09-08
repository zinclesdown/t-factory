extends Node2D
var _正在框选 := false
var _起始点:Vector2
var _当前点:Vector2

func 更新状态(当前是否在框选:bool, 起始点:Vector2)->void:
	_正在框选 =  当前是否在框选
	_起始点 = 起始点
	_当前点 = get_global_mouse_position()


func _draw() -> void:
	if _正在框选:
		draw_rect(Rect2(_起始点, _当前点-_起始点), Color.RED, false)


func _process(_delta: float) -> void:
	queue_redraw()
