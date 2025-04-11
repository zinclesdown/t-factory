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
