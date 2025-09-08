class_name 字符串方法


static func 字典格式化(dict: Dictionary, dictName:String="") -> String:
	var raw_str := ""
	for key:Variant in dict:
		raw_str += "  %s:  %s\n" % [str(key), str(dict[key])]

	#dict.get_typed_key_class_name()
	if dictName:
		return "<%s>: {\n%s}" % [dictName, raw_str]
	else:
		return "<Dict>: {\n%s}" % [raw_str]
