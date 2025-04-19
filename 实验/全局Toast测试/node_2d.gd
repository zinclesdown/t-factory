extends Node2D

# 测试全局Toast功能.

func _on_button_pressed() -> void:
	全局Toast层.发送Toast消息(
		[
			"Hello world!",
			"测试文本sjhadshdkezskfbkhesrjx,gjs",
			"Hi world1!,"
		].pick_random()
	)
