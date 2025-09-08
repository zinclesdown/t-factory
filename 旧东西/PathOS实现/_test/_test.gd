@tool
extends EditorScript
## T2


func _run() -> void:
	
	var res1 := preload("./_test_res.tres").duplicate()
	var res2 := preload("./_test_res.tres").duplicate()
	
	res1.resInfo = 'res1'
	res2.resInfo = 'res2'
	
	print(res1._to_string())
	print(res2._to_string())
	
