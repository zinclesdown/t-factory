@tool
extends EditorScript


func _run() -> void:
	var dict := {
			A=123,
			B=456,
			C=Node2D.new()
	}
	var 字典str = 字符串方法.字典格式化(dict )
	print(字典str)
