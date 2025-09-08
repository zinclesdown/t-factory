@tool
extends EditorScript


func test_dict_format() -> void:
	var dict := {
		A = 123,
		B = 456,
		C = Node2D.new()}
	var 字典str := 字符串方法.字典格式化(dict)
	print(字典str)


func _run() -> void:
	
	print(StringMethods.StringProgressBar(randf()))
	#print(StringMethods.StringProgressBar(randf(), 15, "0"))
	#print(StringMethods.StringProgressBar(randf(), 20, "X", " ", "<", ">") )
