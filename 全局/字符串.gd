class_name 字符串


static func 字典格式化(dict:Dictionary) -> String:
	var raw_str:= ""
	for key in dict:
		raw_str += "    %s - %s\n" % [str(key), str(dict[key])]
	
	#dict.get_typed_key_class_name()
	return "Dict[Key, Value]: {\n%s}" % [raw_str]
