class_name 节点方法


static func 对节点列表按距离进行升序排序(原始节点:Node2D, 节点列表:Array)->void:
	节点列表.sort_custom(
		func(A:Node2D, B:Node2D):
			var lenA := (原始节点.global_position - A.global_position).length()
			var lenB := (原始节点.global_position - B.global_position).length()
			if lenA < lenB:
				return true
			else:
				return false
	)


static func 对节点列表按距离进行降序排序(原始节点:Node2D, 节点列表:Array)->void:
	节点列表.sort_custom(
		func(A:Node2D, B:Node2D):
			var lenA := (原始节点.global_position - A.global_position).length()
			var lenB := (原始节点.global_position - B.global_position).length()
			if lenA > lenB:
				return true
			else:
				return false
	)


## 输入一个节点数组,和Group名
## 输出 仅保留了节点数组内,在Group内的节点的数组.
static func 获取保留列表中组内节点的数组(保留的组名:String, 节点列表:Array)-> Array:
	return 节点列表.filter(
		func(NODE:Node):
			if NODE.is_in_group(保留的组名):
				return true
			else:
				return false
	)
