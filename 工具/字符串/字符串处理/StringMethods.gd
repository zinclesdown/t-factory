class_name StringMethods


## Get the formatted Dict in order to print. you can specify title to make it more readable.
static func GetDictStr(dict: Dictionary, dictName: String = "") -> String:
	return 字符串方法.字典格式化(dict, dictName)


static func StringProgressBar(progress: float, length: int = 10, filled := "#", empty := "-", edge_l := "[", edge_r := "]") -> String:
	var result := ""
	for i in length:
		if i / float(length) <= progress:
			result += filled
		else:
			result += empty
	result = "%s%s%s" % [edge_l, result, edge_r]
	return result
