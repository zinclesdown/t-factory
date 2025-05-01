extends Node2D




func _ready() -> void:
	pass


func _tick_process(delta):
	for node:Node in get_children():
		if node.has_method("_tick_process"):
			node.call("_tick_process", delta)


## TICK. 每（tick）秒执行一次迭代。
func _on_tick_timer_timeout() -> void:
	_tick_process($TickTimer.wait_time)
	
