@tool
class_name _TestCustomResource
extends Resource


@export var resInfo := "nothing."

func _to_string() -> String:
	return "<Custom Test Res: %s>" % resInfo
