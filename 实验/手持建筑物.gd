extends VBoxContainer

@export var 可放置建筑层: 可放置建筑层实例

@onready var 构筑物表信息: RichTextLabel = %构筑物表信息


func _process(delta: float) -> void:
	构筑物表信息.text = ""
	
	构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._位置到构筑物的映射字典) + "\n"
	构筑物表信息.text += "" + 字符串.字典格式化(可放置建筑层._构筑物根位置信息) + "\n"
	
