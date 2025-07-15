class_name NodeMethods


## Sort Node List. Modify the list directly. Do not return any content.
static func SortNodeListViaDistance(target_node: Node2D, nodeList: Array, isAscending: bool = true) -> void:
	节点方法.对节点列表按距离进行排序(target_node, nodeList, isAscending)


## Get nodes from nodeList which belongs to groupName.
static func GetNodeFromListInGroup(groupName: String, nodeList: Array) -> Array:
	return 节点方法.获取保留列表中组内节点的数组(groupName, nodeList)
