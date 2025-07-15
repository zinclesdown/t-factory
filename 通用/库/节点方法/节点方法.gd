class_name 节点方法


## 顾名思义，进行排序。此方法会直接修改节点列表，不会返回任何东西。可指定升序降序。
static func 对节点列表按距离进行排序(原始节点 : Node2D, 节点列表 : Array, 升序 : bool = true) -> void:
	节点列表.sort_custom(
		func(A: Node2D, B: Node2D) -> bool:
		var lenA := (原始节点.global_position - A.global_position).length()
		var lenB := (原始节点.global_position - B.global_position).length()

		if 升序 :
			return(lenA < lenB)
		else:
			return(lenA > lenB)
	)


## 获取包含在 <节点列表> 里，且属于 <保留的组名> 的节点数组。会构建新数组。
static func 获取保留列表中组内节点的数组(保留的组名 : String, 节点列表 : Array) -> Array:
	return 节点列表.filter(
		func(NODE: Node) -> bool:
		if NODE.is_in_group(保留的组名):
			return true
		else:
			return false
	)
